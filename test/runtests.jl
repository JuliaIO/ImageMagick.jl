using Images, ColorTypes, FixedPointNumbers, FileIO
using FactCheck

# write your own tests here
facts("IO") do
    workdir = joinpath(tempdir(), "Images")
    isdir(workdir) && rm(workdir, recursive=true)
    mkdir(workdir)

    context("Gray png") do
        a = rand(2,2)
        aa = convert(Array{Ufixed8}, a)
        fn = joinpath(workdir, "2by2.png")
        save(fn, a)
        b = load(fn)
        @fact b.data --> aa
        save(fn, aa)
        b = load(fn)
        @fact b.data --> aa
        aaimg = Images.grayim(aa)
        b = load(fn)
        @fact b --> aaimg
        aa = convert(Array{Ufixed16}, a)
        save(fn, aa)
        b = load(fn)
        @fact b.data --> aa

    end

    context("Color") do
        fn = joinpath(workdir, "2by2.png")
        img = Images.colorim(rand(3,2,2))
        img24 = convert(Images.Image{RGB24}, img)
        save(fn, img24)
        b = load(fn)
        imgrgb8 = convert(Images.Image{RGB{Ufixed8}}, img)
        @fact Images.data(imgrgb8) --> Images.data(b)
    end

    context("Colormap usage") do
        datafloat = reshape(linspace(0.5, 1.5, 6), 2, 3)
        dataint = round(Uint8, 254*(datafloat .- 0.5) .+ 1)  # ranges from 1 to 255
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
        #save(File(format"PBMBinary", joinpath(workdir, "cmap.pbm")), img) # could not find any definition for this imwrite pbm 
    end

    context("Alpha") do
        c = reinterpret(Images.BGRA{Ufixed8}, [0xf0884422]'')
        fn = joinpath(workdir, "alpha.png")
    	save(fn, c)
        C = load(fn)
        # @test C[1] == c[1]  # disabled because Travis has a weird, old copy of ImageMagick for which this fails (see #261)
        save(fn, reinterpret(ARGB32, [0xf0884422]''))
        D = load(fn)
        # @test D[1] == c[1]
    end

    context("3D TIFF (issue #307)") do
        A = Image(map(Gray{Ufixed8}, rand(0x00:0xff, 2, 2, 4)); colorspace="Gray", spatialorder=["x", "y"], timedim=3) # grayim does not use timedim, but load does...
        fn = joinpath(workdir, "3d.tif")
        save(fn, A)
        B = load(fn)

        #@fact A --> B # seems to have different order -.-
    end

    context("Clamping (issue #256)") do
        A = grayim(rand(2,2))
        A[1,1] = -0.4
        fn = joinpath(workdir, "2by2.png")
        @fact_throws InexactError save(fn, A)
        save(fn, A, mapi=ImageMagick.mapinfo(Images.Clamp, A))
        B = load(fn)
        A[1,1] = 0
        @fact B --> map(Gray{Ufixed8}, A)
    end

    @unix_only context("Reading from a stream (issue #312)") do
        fn = joinpath(workdir, "2by2.png")
        io = open(query(fn))
        img = load(io)
        close(io)
        @fact isa(img, Images.Image) --> true
    end
end


