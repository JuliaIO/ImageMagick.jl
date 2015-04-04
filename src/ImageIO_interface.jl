# register the file endings ImageMagick can read
read(file::File{:jpg}) = read(file, ::Val{:imagemagick})
read(file::File{:png}) = read(file, ::Val{:imagemagick})
read(file::File{:pdf}) = read(file, ::Val{:imagemagick})
read(file::File{:gif}) = read(file, ::Val{:imagemagick})


function read(file::File, ::Type{Val{:imagemagick}})
    wand = LibMagick.MagickWand()
    LibMagick.readimage(wand, file)
    LibMagick.resetiterator(wand)


    imtype = LibMagick.getimagetype(wand)
    # Determine what we need to know about the image format
    sz = size(wand)
    n = LibMagick.getnumberimages(wand)
    if n > 1
        sz = tuple(sz..., n)
    end
    havealpha = LibMagick.getimagealphachannel(wand)
    prop = Dict("spatialorder" => ["x", "y"], "pixelspacing" => [1,1])
    cs = LibMagick.getimagecolorspace(wand)
    if imtype == "GrayscaleType" || imtype == "GrayscaleMatteType"
        cs = "Gray"
    end
    prop["IMcs"] = cs

    depth = LibMagick.getimagechanneldepth(wand, LibMagick.DefaultChannels)
    if depth <= 8
        T = Ufixed8     # always use 8-bit for 8-bit and less
    else
        T = ufixedtype[2*((depth+1)>>1)]  # always use an even # of bits (see issue 242#issuecomment-68845157)
    end

    channelorder = cs
    if havealpha
        if channelorder == "sRGB" || channelorder == "RGB"
            if is_little_endian
                T, channelorder = BGRA{T}, "BGRA"
            else
                T, channelorder = ARGB{T}, "ARGB"
            end
        elseif channelorder == "Gray"
            T, channelorder = GrayAlpha{T}, "IA"
        else
            error("Cannot parse colorspace $channelorder")
        end
    else
        if channelorder == "sRGB" || channelorder == "RGB"
            T, channelorder = RGB{T}, "RGB"
        elseif channelorder == "Gray"
            T, channelorder = Gray{T}, "I"
        else
            error("Cannot parse colorspace $channelorder")
        end
    end
    # Allocate the buffer and get the pixel data
    buf = Array(T, sz...)
    LibMagick.exportimagepixels!(buf, wand, cs, channelorder)
    if n > 1
        prop["timedim"] = ndims(buf)
    end
    Image(buf, prop)
end
