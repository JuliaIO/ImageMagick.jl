using ImageMagick, Images, ColorTypes, FixedPointNumbers, FileIO
using FactCheck
using Compat

ontravis = haskey(ENV, "TRAVIS")

facts("IO") do
    workdir = joinpath(tempdir(), "Images")
    isdir(workdir) && rm(workdir, recursive=true)
    mkdir(workdir)

    context("Binary png") do
        a = rand(Bool,5,5)
        fn = joinpath(workdir, "5by5.png")
        ImageMagick.save(fn, a)
        b = ImageMagick.load(fn)
        a8 = convert(Array{Gray{UFixed8}}, a) # IM won't read back as Bool
        @fact convert(Array, b) --> a8
        aim = grayim(a)
        ImageMagick.save(fn, aim)
        b = ImageMagick.load(fn)
        @fact b --> copyproperties(aim, a8)
        a = bitrand(5,5)
        fn = joinpath(workdir, "5by5.png")
        ImageMagick.save(fn, a)
        b = ImageMagick.load(fn)
        a8 = convert(Array{Gray{UFixed8}}, a)
        @fact convert(Array, b) --> a8
        aim = grayim(a)
        ImageMagick.save(fn, aim)
        b = ImageMagick.load(fn)
        @fact b --> copyproperties(aim, a8)
    end

    context("Gray png") do
        a = [0 1/2^16 1/2^8; 1-1/2^8 1-1/2^16 1]
        aa = convert(Array{UFixed8}, a)
        fn = joinpath(workdir, "2by3.png")
        ImageMagick.save(fn, a)
        b = ImageMagick.load(fn)
        @fact convert(Array, b) --> aa
        ImageMagick.save(fn, aa)
        b = ImageMagick.load(fn)
        @fact convert(Array, b) --> aa
        open(fn, "w") do io
            @compat show(io, MIME("image/png"), b; minpixels=0)
        end
        bb = ImageMagick.load(fn)
        @fact bb.data --> b.data
        aaimg = Images.grayim(aa)
        ImageMagick.save(fn, aaimg)
        b = ImageMagick.load(fn)
        @fact b --> aaimg
        aa = convert(Array{UFixed16}, a)
        ImageMagick.save(fn, aa)
        b = ImageMagick.load(fn)
        @fact eltype(eltype(b)) --> UFixed16
        @fact convert(Array, b) --> aa
    end

    context("Color") do
        fn = joinpath(workdir, "2by2.png")
        A = rand(3,2,2)
        A[1] = 1
        img = Images.colorim(A)
        img24 = convert(Images.Image{RGB24}, img)
        ImageMagick.save(fn, img24)
        b = ImageMagick.load(fn)
        imgrgb8 = convert(Images.Image{RGB{UFixed8}}, img)
        @fact Images.data(imgrgb8) --> Images.data(b)

        open(fn, "w") do io
            @compat show(io, MIME("image/png"), imgrgb8; minpixels=0)
        end
        bb = ImageMagick.load(fn)
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
        ImageMagick.save(joinpath(workdir,"cmap.jpg"), img)
        cmaprgb = Array(RGB, 255) # poorly-typed cmap, issue #336
        cmaprgb[1:128] = [(1-x)*b + x*w for x in f]
        cmaprgb[129:end] = [(1-x)*w + x*r for x in f[2:end]]
        img = Images.ImageCmap(dataint, cmaprgb)
        ImageMagick.save(joinpath(workdir, "cmap.png"), img)
    end

    context("Alpha") do
        c = reinterpret(BGRA{UFixed8}, [0xf0884422]'')
        fn = joinpath(workdir, "alpha.png")
    	ImageMagick.save(fn, c)
        C = ImageMagick.load(fn)
        if !ontravis
            # disabled on Travis because it has a weird, old copy of
            # ImageMagick for which this fails (see Images#261)
            @fact C[1] --> c[1]
        end
        ImageMagick.save(fn, reinterpret(ARGB32, [0xf0884422]''))
        D = ImageMagick.load(fn)
        if !ontravis
            @fact D[1] --> c[1]
        end

        # Images#396
        c = colorim(reshape(collect(0x00:0x11:0xff), 2, 2, 4), "RGBA")
        ImageMagick.save(fn, c)
        D = ImageMagick.load(fn)
        D8 = convert(Image{base_colorant_type(eltype(D)){UFixed8}}, D)
        C = permutedims(convert(Image{eltype(D8)}, c), spatialorder(D8))
        if !ontravis
            for i = 1:length(D8)
                @fact D8[i] --> C[i]
            end
        end
    end

    context("3D TIFF (issue #307)") do
        Ar = rand(0x00:0xff, 2, 2, 4)
        Ar[1] = 0xff
        A = Image(map(x->Gray(UFixed8(x,0)), Ar); colorspace="Gray", spatialorder=["x", "y"], timedim=3) # grayim does not use timedim, but load does...
        fn = joinpath(workdir, "3d.tif")
        ImageMagick.save(fn, A)
        B = ImageMagick.load(fn)

        @fact A --> B
    end

    context("Clamping (issue #256)") do
        Ar = rand(2,2)
        Ar[1] = 1
        A = grayim(Ar)
        A[1,1] = -0.4
        fn = joinpath(workdir, "2by2.png")
        println("The following warning is a sign of normal operation:")
        @fact_throws InexactError ImageMagick.save(fn, A)
        ImageMagick.save(fn, A, mapi=mapinfo(Images.Clamp, A))
        B = ImageMagick.load(fn)
        A[1,1] = 0
        @fact B --> map(Gray{UFixed8}, A)
    end

    is_unix() && context("Reading from a stream (issue #312)") do
        fn = joinpath(workdir, "2by2.png")
        img = open(fn) do io
            ImageMagick.load(io)
        end
        @fact isa(img, Images.Image) --> true
    end

    is_unix() && context("Writing to a stream (PR #22)") do
        orig_img = ImageMagick.load(joinpath(workdir, "2by2.png"))
        fn = joinpath(workdir, "2by2_fromstream.png")
        open(fn, "w") do f
            ImageMagick.save(Stream(format"PNG", f), orig_img)
        end
        img = ImageMagick.load(fn)
        @fact img --> orig_img
    end

    is_unix() && context("Reading from a byte array (issue #279)") do
        fn = joinpath(workdir, "2by2.png")
        io = open(fn)
        arr = read(io)
        close(io)
        img = readblob(arr)
        @fact isa(img, Images.Image) --> true
    end

    context("show(MIME)") do
        Ar = rand(UInt8, 3, 2, 2)
        Ar[1] = typemax(eltype(Ar))
        a = colorim(Ar)
        fn = joinpath(workdir, "2by2.png")
        open(fn, "w") do file
            @compat show(file, MIME("image/png"), a, minpixels=0)
        end
        b = ImageMagick.load(fn)
        @fact data(b) --> data(a)

        Ar = rand(UInt8, 3, 1021, 1026)
        Ar[1] = typemax(eltype(Ar))
        abig = colorim(Ar)
        fn = joinpath(workdir, "big.png")
        open(fn, "w") do file
            @compat show(file, MIME("image/png"), abig, maxpixels=10^6)
        end
        b = ImageMagick.load(fn)
        @fact data(b) --> convert(Array{RGB{UFixed8},2}, data(restrict(abig, (1,2))))

        # Issue #269
        Ar = rand(UInt16, 3, 1024, 1023)
        Ar[1] = typemax(eltype(Ar))
        abig = colorim(Ar)
        open(fn, "w") do file
            @compat show(file, MIME("image/png"), abig, maxpixels=10^6)
        end
        b = ImageMagick.load(fn)
        @fact data(b) --> convert(Array{RGB{UFixed8},2}, data(restrict(abig, (1,2))))
    end

end
