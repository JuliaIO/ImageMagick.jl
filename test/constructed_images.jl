using ImageMagick, IndirectArrays, FileIO, OffsetArrays, ImageMetadata, ImageTransformations
using ImageShow       # for show(io, ::MIME, img) & ImageMeta
using Test
using ImageCore, ColorVectorSpace
using Random, Base.CoreLogging

mutable struct TestType end

@testset "IO" begin
    workdir = joinpath(tempdir(), "Images")
    isdir(workdir) && rm(workdir, recursive=true)
    mkdir(workdir)

    a = rand(Bool,5,5,5,5)
    fn = joinpath(workdir, "5by5.png")
    @test_throws ErrorException ImageMagick.save(fn, a)

    a = [TestType() TestType()]
    fn = joinpath(workdir, "5by5.png")
    io = IOBuffer()
    with_logger(SimpleLogger(io)) do  # suppress warning
        @test_throws MethodError ImageMagick.save(fn, a)
    end
    @test occursin("out-of-range", String(take!(io)))

    @testset "Binary png" begin
        a = rand(Bool,5,5)
        fn = joinpath(workdir, "5by5.png")
        ImageMagick.save(fn, a)
        b = ImageMagick.load(fn)
        ag = convert(Array{Gray{Bool}}, a) # IM won't read back as Bool
        @test b == ag
        @test eltype(b) ∈ (Bool, Gray{Bool})
        aim = colorview(Gray, a)
        ImageMagick.save(fn, aim)
        b = ImageMagick.load(fn)
        @test b == ag
        a = bitrand(5,5)
        fn = joinpath(workdir, "5by5.png")
        ImageMagick.save(fn, a)
        b = ImageMagick.load(fn)
        ag = convert(Array{Gray{Bool}}, a)
        @test b == ag
        aim = colorview(Gray, a)
        ImageMagick.save(fn, aim)
        b = ImageMagick.load(fn)
        @test b == ag

        @test ImageMagick.metadata(fn) == ((5,5), Gray{Bool})

        # If we try to save as JPG, don't error
        fn = joinpath(workdir, "5by5.jpg")
        ImageMagick.save(fn, a)
        b = ImageMagick.load(fn)
        @test eltype(b) == Gray{N0f8}
    end

    @testset "Gray png" begin
        a = [0 1/2^16 1/2^8; 1-1/2^8 1-1/2^16 1]
        aa = convert(Array{N0f8}, a)
        fn = joinpath(workdir, "2by3.png")
        ImageMagick.save(fn, a)
        b = ImageMagick.load(fn)
        @test b == aa
        ImageMagick.save(fn, aa)
        b = ImageMagick.load(fn)
        @test b == aa
        open(fn, "w") do io
            show(io, MIME("image/png"), b; minpixels=0)
        end
        bb = ImageMagick.load(fn)
        @test bb == b
        aaimg = Gray.(aa)
        ImageMagick.save(fn, aaimg)
        b = ImageMagick.load(fn)
        @test b == aaimg
        aa = convert(Array{N0f16}, a)
        ImageMagick.save(fn, aa)
        b = ImageMagick.load(fn)
        @test eltype(eltype(b)) == N0f16
        # Gets loaded as RGB{N0f16} on windows/osx
        @test N0f16.(Gray.(b)) == aa
        m = ImageMagick.metadata(fn)
        @test m[1]==(3,2)
    end

    @testset "Color" begin
        fn = joinpath(workdir, "2by2.png")
        A = rand(3,2,2)
        A[1] = 1
        img = colorview(RGB, A)
        img24 = convert(Array{RGB24}, img)
        ImageMagick.save(fn, img24)
        b = ImageMagick.load(fn)
        imgrgb8 = convert(Array{RGB{N0f8}}, img)
        @test imgrgb8 == b

        open(fn, "w") do io
            show(io, MIME("image/png"), imgrgb8; minpixels=0)
        end
        bb = ImageMagick.load(fn)
        @test bb == imgrgb8
    end

    @testset "Colormap usage" begin
        datafloat = reshape(range(0.5, stop=1.5, length=6), 2, 3)
        dataint = round.([UInt8], 254*(datafloat .- 0.5) .+ 1)  # ranges from 1 to 255
        # build our colormap
        b = RGB(0,0,1)
        w = RGB(1,1,1)
        r = RGB(1,0,0)
        cmaprgb = Array{RGB{Float64}}(undef, 255)
        f = range(0, stop=1, length=128)
        cmaprgb[1:128] = [(1-x)*b + x*w for x in f]
        cmaprgb[129:end] = [(1-x)*w + x*r for x in f[2:end]]
        img = IndirectArray(dataint, cmaprgb)
        ImageMagick.save(joinpath(workdir,"cmap.jpg"), img)
        cmaprgb = Array{RGB}(undef, 255) # poorly-typed cmap, Images issue #336
        cmaprgb[1:128] = [(1-x)*b + x*w for x in f]
        cmaprgb[129:end] = [(1-x)*w + x*r for x in f[2:end]]
        img = IndirectArray(dataint, cmaprgb)
        ImageMagick.save(joinpath(workdir, "cmap.png"), img)
    end

    @testset "Alpha" begin
        c = reinterpret(BGRA{N0f8}, [0xf0884422]'')
        fn = joinpath(workdir, "alpha.png")
        ImageMagick.save(fn, c)
        C = ImageMagick.load(fn)
        @test C[1] == c[1]
        ImageMagick.save(fn, reinterpret(ARGB32, [0xf0884422]''))
        D = ImageMagick.load(fn)
        @test D[1] == c[1]

        # Images#396
        c = colorview(RGBA, normedview(permuteddimsview(reshape(0x00:0x11:0xff, 2, 2, 4), (3,1,2))))
        ImageMagick.save(fn, c)
        D = ImageMagick.load(fn)
        @test D == c
    end

    @testset "3D TIFF" begin
        # issue #307
        Ar = rand(0x00:0xff, 2, 2, 4)
        Ar[1] = 0xff
        A = map(x->Gray(N0f8(x,0)), Ar)
        fn = joinpath(workdir, "3d.tif")
        ImageMagick.save(fn, A)
        B = ImageMagick.load(fn)

        @test A == B

        @test ImageMagick.metadata(fn) == ((2,2,4), Gray{N0f8})

        # ensure proper colordepth if first image is black
        A = cat(N0f8[0 0; 0 0], N0f8[0 0.2; 0.4 0.8]; dims=3)
        fn = joinpath(workdir, "3dblack.tif")
        ImageMagick.save(fn, A)
        B = ImageMagick.load(fn)
        @test A == B
    end

    @testset "16-bit TIFF (issue #49)" begin
        Ar = rand(0x0000:0xffff, 2, 2, 4)
        Ar[1] = 0xffff
        A = map(x->Gray(reinterpret(N0f16, x)), Ar)
        fn = joinpath(workdir, "3d16.tif")
        ImageMagick.save(fn, Ar)
        ImageMagick.save(fn, A)
        B = ImageMagick.load(fn)

        @test A == B
    end

    # @testset "32-bit TIFF (issue #49)" begin
    #     Ar = rand(0x00000000:0xffffffff, 2, 2, 4)
    #     Ar[1] = 0xffffffff
    #     A = map(x->Gray(reinterpret(N0f32, x)), Ar)
    #     fn = joinpath(workdir, "3d32.tif")
    #     ImageMagick.save(fn, A)
    #     B = ImageMagick.load(fn)
    #
    #     @test A == B
    # end

    @testset "Clamping (issue #256)" begin
        Ar = rand(2,2)
        Ar[1] = 1
        A = colorview(Gray, Ar)
        A[1,1] = -0.4
        fn = joinpath(workdir, "2by2.png")
        errfile, io = mktemp()
        with_logger(SimpleLogger(io)) do
            @test_throws ArgumentError ImageMagick.save(fn, A)
        end
        close(io)
        @test occursin("out-of-range", readlines(errfile)[1])
        rm(errfile)
        ImageMagick.save(fn, A, mapi=clamp01nan)
        B = ImageMagick.load(fn)
        A[1,1] = 0
        @test B == map(Gray{N0f8}, A)
    end

    Sys.isunix() && @testset "Reading from a stream (issue #312)" begin
        fn = joinpath(workdir, "2by2.png")
        img = open(fn) do io
            ImageMagick.load(io)
        end
        @test size(img) == (2,2)
    end

    Sys.isunix() && @testset "Writing to a stream (PR #22)" begin
        orig_img = ImageMagick.load(joinpath(workdir, "2by2.png"))
        fn = joinpath(workdir, "2by2_fromstream.png")
        open(fn, "w") do f
            ImageMagick.save(Stream(format"PNG", f), orig_img)
        end
        img = ImageMagick.load(fn)
        @test img == orig_img
    end

    Sys.isunix() && @testset "Reading from a byte array (issue #279)" begin
        fn = joinpath(workdir, "2by2.png")
        io = open(fn)
        arr = read(io)
        close(io)
        img = readblob(arr)
        @test size(img) == (2,2)
    end

    @testset "show(MIME)" begin
        Ar = rand(UInt8, 3, 2, 2)
        Ar[1] = typemax(eltype(Ar))
        a = colorview(RGB, normedview(Ar))
        fn = joinpath(workdir, "2by2.png")
        open(fn, "w") do file
            show(file, MIME("image/png"), a, minpixels=0)
        end
        b = ImageMagick.load(fn)
        @test b == a

        Ar = rand(UInt8, 3, 1021, 1026)
        Ar[1] = typemax(eltype(Ar))
        abig = colorview(RGB, normedview(Ar))
        fn = joinpath(workdir, "big.png")
        open(fn, "w") do file
            show(file, MIME("image/png"), abig, maxpixels=10^6)
        end
        b = ImageMagick.load(fn)
        @test b == convert(Array{RGB{N0f8},2}, restrict(abig, (1,2)))

        # Issue #269
        Ar = rand(UInt16, 3, 1024, 1023)
        Ar[1] = typemax(eltype(Ar))
        abig = colorview(RGB, normedview(N0f16, Ar))
        open(fn, "w") do file
            show(file, MIME("image/png"), abig, maxpixels=10^6)
        end
        b = ImageMagick.load(fn)
        @test b == convert(Array{RGB{N0f8},2}, restrict(abig, (1,2)))
    end

    @testset "fps" begin
        A = rand(RGB{N0f8}, 100, 100, 5)
        fn = joinpath(workdir, "animated.gif")
        ImageMagick.save(fn, A, fps=2)
        wand = MagickWand()
        readimage(wand, fn)
        resetiterator(wand)
        @test ImageMagick.getimagedelay(wand) == 50
    end

    @testset "ImageMeta" begin
        # https://github.com/sisl/PGFPlots.jl/issues/5
        img = ImageMeta(rand(RGB{N0f8},3,5))
        fn = joinpath(workdir, "imagemeta.png")
        ImageMagick.save(fn, img)
        imgr = ImageMagick.load(fn)
        @test imgr == img
    end

    @testset "OffsetArrays" begin
        img = OffsetArray([true false; false true], 0:1, 3:4)
        fn = joinpath(workdir, "indices.png")
        ImageMagick.save(fn, img)
        imgr = ImageMagick.load(fn)
        @test imgr == parent(img)
    end

    @testset "permute_horizontal" begin
        Ar = [0x00 0xff; 0x00 0x00]
        A = map(x->Gray(N0f8(x,0)), Ar)
        fn = joinpath(workdir, "2d.tif")

        ImageMagick.save(fn, A)
        B = ImageMagick.load(fn)
        @test A==B

        ImageMagick.save(fn, A, false)
        B = ImageMagick.load(fn, false)
        @test A==B

        ImageMagick.save(fn, A, true)
        B = ImageMagick.load(fn, false)
        @test A==transpose(B)

        ImageMagick.save(fn, A, false)
        B = ImageMagick.load(fn, true)
        @test transpose(A)==B
    end

    @testset "exportimagepixels!()" begin
        # test the direct use of exportimagepixels!()
        Ar = [0x10 0xff 0x80; 0x00 0x00 0x20]
        A = Gray.(N0f8.(Ar, 0))
        fn = joinpath(workdir, "2d.tif")
        ImageMagick.save(fn, A, false)

        wand = MagickWand()
        readimage(wand, fn)
        @test ImageMagick.getnumberimages(wand) == 1
        ImageMagick.resetiterator(wand)
        sz, T, cs, channelorder = ImageMagick._metadata(wand)
        @test sz == size(Ar)
        @test T == Gray{N0f8}
        # test using the array
        buf = Array{UInt8}(undef, sz)
        exportimagepixels!(buf, wand, cs, channelorder)
        @test buf == Ar

        # test using the subarray
        buf2 = similar(buf, ntuple(i -> i <= length(sz) ? sz[i] + 1 : 2, length(sz) + 1))
        buf2view = view(buf2, 1:sz[1], 1:sz[2], 2)
        exportimagepixels!(buf2view, wand, cs, channelorder)
        @test buf2view == Ar
    end
end
