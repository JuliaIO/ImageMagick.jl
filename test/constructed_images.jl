using ImageMagick, Images, ColorTypes, FixedPointNumbers, FileIO
using FactCheck

facts("IO") do
    workdir = joinpath(tempdir(), "Images")
    isdir(workdir) && rm(workdir, recursive=true)
    mkdir(workdir)

    context("Gray png") do
        a = rand(2,2)
        a[1,1] = 1
        aa = convert(Array{UFixed8}, a)
        fn = joinpath(workdir, "2by2.png")
        save(fn, a)
        b = load(fn)
        @fact convert(Array, b) --> aa
        save(fn, aa)
        b = load(fn)
        @fact convert(Array, b) --> aa
        open(fn, "w") do io
            writemime(io, MIME("image/png"), b; minpixels=0)
        end
        bb = load(fn)
        @fact bb.data --> b.data
        aaimg = Images.grayim(aa)
        save(fn, aaimg)
        b = load(fn)
        @fact b --> aaimg
        aa = convert(Array{UFixed16}, a)
        save(fn, aa)
        b = load(fn)
        @fact convert(Array, b) --> aa
    end

    context("Color") do
        fn = joinpath(workdir, "2by2.png")
        A = rand(3,2,2)
        A[1] = 1
        img = Images.colorim(A)
        img24 = convert(Images.Image{RGB24}, img)
        save(fn, img24)
        b = load(fn)
        imgrgb8 = convert(Images.Image{RGB{UFixed8}}, img)
        @fact Images.data(imgrgb8) --> Images.data(b)

        open(fn, "w") do io
            writemime(io, MIME("image/png"), imgrgb8; minpixels=0)
        end
        bb = load(fn)
        @fact data(bb) --> data(imgrgb8)
    end

    context("Colormap usage") do
        datafloat = reshape(linspace(0.5, 1.5, 6), 2, 3)
        dataint = round(UInt8, 254*(datafloat .- 0.5) .+ 1)  # ranges from 1 to 255
        # build our colormap
        b = RGB(0,0,1)
        w = RGB(1,1,1)
        r = RGB(1,0,0)
        cmaprgb = Array(RGB{Float64}, 255)
        f = linspace(0,1,128)
        cmaprgb[1:128] = [(1-x)*b + x*w for x in f]
        cmaprgb[129:end] = [(1-x)*w + x*r for x in f[2:end]]
        img = Images.ImageCmap(dataint, cmaprgb)
        save(joinpath(workdir,"cmap.jpg"), img)
        cmaprgb = Array(RGB, 255) # poorly-typed cmap, issue #336
        cmaprgb[1:128] = [(1-x)*b + x*w for x in f]
        cmaprgb[129:end] = [(1-x)*w + x*r for x in f[2:end]]
        img = Images.ImageCmap(dataint, cmaprgb)
        save(joinpath(workdir, "cmap.png"), img)
    end

    context("Alpha") do
        c = reinterpret(Images.BGRA{UFixed8}, [0xf0884422]'')
        fn = joinpath(workdir, "alpha.png")
    	save(fn, c)
        C = load(fn)
        # @test C[1] == c[1]  # disabled because Travis has a weird, old copy of ImageMagick for which this fails (see #261)
        save(fn, reinterpret(ARGB32, [0xf0884422]''))
        D = load(fn)
        # @test D[1] == c[1]
    end

    context("3D TIFF (issue #307)") do
        Ar = rand(0x00:0xff, 2, 2, 4)
        Ar[1] = 0xff
        A = Image(map(x->Gray(UFixed8(x,0)), Ar); colorspace="Gray", spatialorder=["x", "y"], timedim=3) # grayim does not use timedim, but load does...
        fn = joinpath(workdir, "3d.tif")
        save(fn, A)
        B = load(fn)

        @fact A --> B
    end

    context("Clamping (issue #256)") do
        Ar = rand(2,2)
        Ar[1] = 1
        A = grayim(Ar)
        A[1,1] = -0.4
        fn = joinpath(workdir, "2by2.png")
        println("The following InexactError is a sign of normal operation:")
        @fact_throws InexactError save(fn, A)
        save(fn, A, mapi=mapinfo(Images.Clamp, A))
        B = load(fn)
        A[1,1] = 0
        @fact B --> map(Gray{UFixed8}, A)
    end

    @unix_only context("Reading from a stream (issue #312)") do
        fn = joinpath(workdir, "2by2.png")
        io = open(fn)
        img = load(io)
        @fact isa(img, Images.Image) --> true
        close(io)
    end

    @unix_only context("Reading from a byte array (issue #279)") do
        fn = joinpath(workdir, "2by2.png")
        io = open(fn)
        arr = readbytes(io)
        close(io)
        img = readblob(arr)
        @fact isa(img, Images.Image) --> true
    end

    context("writemime") do
        Ar = rand(UInt8, 3, 2, 2)
        Ar[1] = typemax(eltype(Ar))
        a = colorim(Ar)
        fn = joinpath(workdir, "2by2.png")
        open(fn, "w") do file
            writemime(file, MIME("image/png"), a, minpixels=0)
        end
        b = load(fn)
        @fact data(b) --> data(a)

        Ar = rand(UInt8, 3, 1021, 1026)
        Ar[1] = typemax(eltype(Ar))
        abig = colorim(Ar)
        fn = joinpath(workdir, "big.png")
        open(fn, "w") do file
            writemime(file, MIME("image/png"), abig, maxpixels=10^6)
        end
        b = load(fn)
        @fact data(b) --> convert(Array{RGB{UFixed8},2}, data(restrict(abig, (1,2))))

        # Issue #269
        Ar = rand(UInt16, 3, 1024, 1023)
        Ar[1] = typemax(eltype(Ar))
        abig = colorim(Ar)
        open(fn, "w") do file
            writemime(file, MIME("image/png"), abig, maxpixels=10^6)
        end
        b = load(fn)
        @fact data(b) --> convert(Array{RGB{UFixed8},2}, data(restrict(abig, (1,2))))
    end

end
