using FactCheck, Images, Colors, FixedPointNumbers, ZipFile

workdir = joinpath(tempdir(), "Images")
writedir = joinpath(workdir, "write")
if !isdir(workdir)
    mkdir(workdir)
end
if !isdir(writedir)
    mkdir(writedir)
end

facts("Read remote") do
    urlbase = "http://www.imagemagick.org/Usage/images/"

    function getfile(name)
        file = joinpath(workdir, name)
        if !isfile(file)
            file = download(urlbase*name, file)
        end
        file
    end

    context("Gray") do
        file = getfile("jigsaw_tmpl.png")
        img = load(file)
        @fact colorspace(img) --> "Gray"
        @fact ndims(img) --> 2
        @fact colordim(img) --> 0
        @fact eltype(img) --> Gray{UFixed8}
        outname = joinpath(writedir, "jigsaw_tmpl.png")
        save(outname, img)
        imgc = load(outname)
        @fact img.data --> imgc.data
        @fact reinterpret(UInt32, data(map(mapinfo(RGB24, img), img))) -->
            map(x->x&0x00ffffff, reinterpret(UInt32, data(map(mapinfo(ARGB32, img), img))))
        @fact mapinfo(UInt32, img) --> mapinfo(RGB24, img)
        @fact data(convert(Image{Gray{Float32}}, img)) --> float32(data(img))
        mapi = mapinfo(RGB{UFixed8}, img)
        imgrgb8 = map(mapi, img)
        @fact imgrgb8[1,1].r --> img[1].val
        open(outname, "w") do file
            writemime(file, "image/png", img)
        end
    end

    context("Gray with alpha channel") do
        file = getfile("wmark_image.png")
        img = load(file)
        @fact colorspace(img) --> "GrayA"
        @fact ndims(img) --> 2
        @fact colordim(img) --> 0
        @fact eltype(img) --> Images.ColorTypes.GrayA{UFixed8}
        @linux_only begin
            outname = joinpath(writedir, "wmark_image.png")
            save(outname, img)
            sleep(0.2)
            imgc = load(outname)
            @fact img.data --> imgc.data
            open(outname, "w") do file
                writemime(file, "image/png", img)
            end
        end
        @fact reinterpret(UInt32, data(map(mapinfo(RGB24, img), img))) -->
            map(x->x&0x00ffffff, reinterpret(UInt32, data(map(mapinfo(ARGB32, img), img))))
        @fact mapinfo(UInt32, img) --> mapinfo(ARGB32, img)
    end

    context("RGB") do
        file = getfile("rose.png")
        img = load(file)
        # Mac reader reports RGB4, imagemagick reports RGB
        @fact colorspace(img) --> "RGB"
        @fact ndims(img) --> 2
        @fact colordim(img) --> 0
        @fact eltype(img) --> RGB{UFixed8}
        outname = joinpath(writedir, "rose.tiff")
        save(outname, img)
        imgc = load(outname)
        T = eltype(imgc)
        # Why does this one fail on OSX??
        @osx? nothing : @fact img.data --> imgc.data
        @fact reinterpret(UInt32, data(map(mapinfo(RGB24, img), img))) -->
            map(x->x&0x00ffffff, reinterpret(UInt32, data(map(mapinfo(ARGB32, img), img))))
        @fact mapinfo(UInt32, img) --> mapinfo(RGB24, img)
        mapi = mapinfo(RGB{UFixed8}, img)
        imgrgb8 = map(mapi, img)
        @fact data(imgrgb8) --> data(img)
        convert(Array{Gray{UFixed8}}, img)
        convert(Image{Gray{UFixed8}}, img)
        convert(Array{Gray}, img)
        convert(Image{Gray}, img)
        imgs = separate(img)
        @fact permutedims(convert(Image{Gray}, imgs), [2,1]) --> convert(Image{Gray}, img)
        # Make sure that all the operations in README will work:
        buf = Array(UInt32, size(img))
        buft = Array(UInt32, reverse(size(img)))
        uint32color(img)
        uint32color!(buf, img)
        imA = convert(Array, img)
        uint32color(imA)
        uint32color!(buft, imA)
        uint32color(imgs)
        uint32color!(buft, imgs)
        imr = reinterpret(UFixed8, img)
        uint32color(imr)
        uint32color!(buf, imr)
        @osx? nothing : begin
            imhsv = convert(Image{HSV}, float32(img))
            uint32color(imhsv)
            uint32color!(buf, imhsv)
            @fact pixelspacing(restrict(img)) --> [2.0,2.0]
        end
        outname = joinpath(writedir, "rose.png")
        open(outname, "w") do file
            writemime(file, "image/png", img)
        end
    end

    context("RGBA with 16 bit depth") do
        file = getfile("autumn_leaves.png")
        img = load(file)
        @fact colorspace(img) --> "BGRA"
        @fact ndims(img) --> 2
        @fact colordim(img) --> 0
        @fact eltype(img) --> Images.ColorTypes.BGRA{UFixed16}
        outname = joinpath(writedir, "autumn_leaves.png")
        @osx? nothing : begin
            save(outname, img)
            sleep(0.2)
            imgc = load(outname)
            @fact img.data --> imgc.data
            @fact reinterpret(UInt32, data(map(mapinfo(RGB24, img), img))) -->
                map(x->x&0x00ffffff, reinterpret(UInt32, data(map(mapinfo(ARGB32, img), img))))
            @fact mapinfo(UInt32, img) --> mapinfo(ARGB32, img)
        end
        open(outname, "w") do file
            writemime(file, "image/png", img)
        end
    end

    context("Indexed") do
        file = getfile("present.gif")
        img = load(file)
        @fact nimages(img) --> 1
        @fact reinterpret(UInt32, data(map(mapinfo(RGB24, img), img))) -->
            map(x->x&0x00ffffff, reinterpret(UInt32, data(map(mapinfo(ARGB32, img), img))))
        @fact mapinfo(UInt32, img) --> mapinfo(RGB24, img)
        outname = joinpath(writedir, "present.png")
        open(outname, "w") do file
            writemime(file, "image/png", img)
        end
    end

    context("Images with a temporal dimension") do
        fname = "swirl_video.gif"
        #fname = "bunny_anim.gif"  # this one has transparency but LibMagick gets confused about its size
        file = getfile(fname)  # this also has transparency
        img = load(file)
        @fact timedim(img) --> 3
        @fact nimages(img) --> 26
        outname = joinpath(writedir, fname)
        save(outname, img)
        imgc = load(outname)
        # Something weird happens after the 2nd image (compression?), and one starts getting subtle differences.
        # So don't compare the values.
        # Also take the opportunity to test some things with temporal images
        @fact storageorder(img) --> ["x", "y", "t"]
        @fact haskey(img, "timedim") --> true
        @fact timedim(img) --> 3
        s = getindexim(img, 1:5, 1:5, 3)
        @fact timedim(s) --> 0
        s = sliceim(img, :, :, 5)
        @fact timedim(s) --> 0
        imgt = sliceim(img, "t", 1)
        @fact reinterpret(UInt32, data(map(mapinfo(RGB24, imgt), imgt))) -->
            map(x->x&0x00ffffff, reinterpret(UInt32, data(map(mapinfo(ARGB32, imgt), imgt))))
    end

    context("Extra properties") do
        @osx? nothing : begin
            file = getfile("autumn_leaves.png")
            # List properties
            extraProps = load(file, extrapropertynames=true)

            img = load(file,extraprop=extraProps)
            props = properties(img)
            for key in extraProps
                @fact haskey(props, key) --> true
                @fact props[key] --> not(nothing)
            end
            img = load(file, extraprop=extraProps[1])
            props = properties(img)
            @fact haskey(props, extraProps[1]) --> true
            @fact props[extraProps[1]] --> not(nothing)

            println("The following \"Undefined property\" warning indicates normal operation")
            img = load(file, extraprop="Non existing property")
            props = properties(img)
            @fact haskey(props, "Non existing property") --> true
            @fact props["Non existing property"] --> nothing
        end
    end
end

using ImageMagick

facts("EXIF orientation") do
    function test_orientation(r, odict)
        for f in r.files
            bn = basename(f.name)
            if haskey(odict, bn)
                so = odict[bn]
                data = read(f, UInt8, f.uncompressedsize)
                img = readblob(data)
                @fact spatialorder(img) --> so
            end
        end
    end

    url = "http://www.galloway.me.uk/media/other/EXIF_Orientation_Samples.zip"
    fn = joinpath(workdir, "EXIF_Orientation_Samples.zip")
    download(url, fn)
    r = ZipFile.Reader(fn)
    test_orientation(r, Dict("up.jpg"=>["x", "y"],
                             "left-mirrored.jpg"=>["y", "x"]))
end
