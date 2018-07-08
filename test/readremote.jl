using ImageMagick
using FileIO, Colors, FixedPointNumbers, ZipFile
using Test

workdir = joinpath(tempdir(), "Images")
writedir = joinpath(workdir, "write")
if !isdir(workdir)
    mkdir(workdir)
end
if !isdir(writedir)
    mkdir(writedir)
end

@testset "Read remote" begin
    urlbase = "http://www.imagemagick.org/Usage/images/"

    function getfile(name)
        file = joinpath(workdir, name)
        if !isfile(file)
            file = download(urlbase*name, file)
        end
        file
    end

    @testset "Gray" begin
        file = getfile("jigsaw_tmpl.png")
        img = ImageMagick.load(file)
        @test ImageMagick.metadata(file) == (reverse(size(img)), Gray{N0f8})
        @test eltype(img) == Gray{N0f8}
        @test ndims(img) == 2
        outname = joinpath(writedir, "jigsaw_tmpl.png")
        ImageMagick.save(outname, img)
        imgc = ImageMagick.load(outname)
        @test img == imgc
        @test reinterpret(UInt32, map(RGB24, img)) ==
            map(x->x&0x00ffffff, reinterpret(UInt32, map(ARGB32, img)))
        @test convert(Array{Gray{Float32}}, img) == float32.(img)
        imgrgb8 = map(RGB{N0f8}, img)
        @test imgrgb8[1,1].r == img[1].val
        open(outname, "w") do file
            show(file, MIME("image/png"), img)
        end
    end

    @testset "Gray with alpha channel" begin
        file = getfile("wmark_image.png")
        img = ImageMagick.load(file)
        m = ImageMagick.metadata(file)
        @test m[1] == reverse(size(img))
        @test ndims(img) == 2
        @test eltype(img) in (GrayA{N0f8}, RGBA{N0f8})
        if Sys.islinux()
            outname = joinpath(writedir, "wmark_image.png")
            ImageMagick.save(outname, img)
            sleep(0.2)
            imgc = ImageMagick.load(outname)
            @test img == imgc
            open(outname, "w") do file
                show(file, MIME("image/png"), img)
            end
        end
        @test reinterpret(UInt32, map(RGB24, img)) ==
            map(x->x&0x00ffffff, reinterpret(UInt32, map(ARGB32, img)))
    end

    @testset "RGB" begin
        file = getfile("rose.png")
        img = ImageMagick.load(file)
        @test ImageMagick.metadata(file) == (reverse(size(img)), RGB{N0f8})
        # Mac reader reports RGB4, imagemagick reports RGB
        @test ndims(img) == 2
        @test eltype(img) == RGB{N0f8}
        outname = joinpath(writedir, "rose.tiff")
        ImageMagick.save(outname, img)
        imgc = ImageMagick.load(outname)
        T = eltype(imgc)
        # Why does this one fail on OSX??
        Sys.isapple() || @test img == imgc
        @test reinterpret(UInt32, map(RGB24, img)) ==
            map(x->x&0x00ffffff, reinterpret(UInt32, map(ARGB32, img)))
        imgrgb8 = map(RGB{N0f8}, img)
        @test imgrgb8 == img
        outname = joinpath(writedir, "rose.png")
        open(outname, "w") do file
            show(file, MIME("image/png"), img)
        end
    end

    @testset "RGBA with 16 bit depth" begin
        file = getfile("autumn_leaves.png")
        img = ImageMagick.load(file)
        @test ImageMagick.metadata(file) == (reverse(size(img)), RGBA{N0f16})
        @test ndims(img) == 2
        @test eltype(img) == RGBA{N0f16}
        outname = joinpath(writedir, "autumn_leaves.png")
        Sys.isapple() || begin
            ImageMagick.save(outname, img)
            sleep(0.2)
            imgc = ImageMagick.load(outname)
            @test img == imgc
            @test reinterpret(UInt32, map(RGB24, img)) ==
                map(x->x&0x00ffffff, reinterpret(UInt32, map(ARGB32, img)))
        end
        open(outname, "w") do file
            show(file, MIME("image/png"), img)
        end
    end

    @testset "Indexed" begin
        file = getfile("present.gif")
        img = ImageMagick.load(file)
        @test ImageMagick.metadata(file) == (reverse(size(img)), RGB{N0f8})
        @test nimages(img) == 1
        @test reinterpret(UInt32, map(RGB24, img)) ==
            map(x->x&0x00ffffff, reinterpret(UInt32, map(ARGB32, img)))
        outname = joinpath(writedir, "present.png")
        open(outname, "w") do file
            show(file, MIME("image/png"), img)
        end
    end

    @testset "Images with a temporal dimension" begin
        fname = "swirl_video.gif"
        #fname = "bunny_anim.gif"  # this one has transparency but LibMagick gets confused about its size
        file = getfile(fname)  # this also has transparency
        img = ImageMagick.load(file)
        @test ImageMagick.metadata(file) == (size(img)[[2,1,3]], RGB{N0f8})
        @test size(img, 3) == 26
        outname = joinpath(writedir, fname)
        ImageMagick.save(outname, img)
        imgc = ImageMagick.load(outname)
        @test size(img) == size(imgc)
        @test img == imgc
    end

    @testset "Extra properties" begin
        Sys.isapple() || begin
            file = getfile("autumn_leaves.png")
            # List properties
            extraProps = magickinfo(file)
            @show extraProps

            img = ImageMagick.load(file)
            @test ImageMagick.metadata(file) == (reverse(size(img)), RGBA{N0f16})
            props = magickinfo(file, extraProps)
            for key in extraProps
                @test haskey(props, key) == true
                @test props[key] != nothing
            end

            props = magickinfo(file, extraProps[1])
            @test haskey(props, extraProps[1]) == true
            @test props[extraProps[1]] != nothing

            warnfile, io = mktemp()
            props = redirect_stderr(io) do
                magickinfo(file, "Nonexistent property")
            end
            close(io)
            @test haskey(props, "Nonexistent property") == true
            @test props["Nonexistent property"] == nothing
        end
    end
end

@testset "EXIF orientation" begin
    url = "http://magnushoff.com/assets/test-exiforientation.zip"
    fn = joinpath(workdir, "test-exiforientation.zip")
    download(url, fn)
    first_img = true
    r = ZipFile.Reader(fn)
    local img0
    for f in r.files
        data = read!(f, Array{UInt8}(undef, f.uncompressedsize...))
        if first_img
            img0 = readblob(data)
            first_img = false
        else
            img = readblob(data)
            @test all(img0.==img) == true
        end
    end
    ZipFile.close(r)
end

nothing
