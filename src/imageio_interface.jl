module ImageMagickIO

using FixedPointNumbers, ColorTypes, Compat, ImageIO
const is_little_endian = ENDIAN_BOM == 0x04030201

include("libmagickwand.jl")
export MagickWand
export constituteimage
export exportimagepixels!
export getblob
export getimagealphachannel
export getimagecolorspace
export getimagedepth
export getnumberimages
export importimagepixels
export readimage
export resetiterator
export setimagecolorspace
export setimagecompression
export setimagecompressionquality
export setimageformat
export writeimage


function imagemagickread(file::AbstractString)
    wand = MagickWand()
    readimage(wand, file)
    resetiterator(wand)


    imtype = getimagetype(wand)
    # Determine what we need to know about the image format
    sz = size(wand)
    n = getnumberimages(wand)
    if n > 1
        sz = tuple(sz..., n)
    end
    havealpha = getimagealphachannel(wand)
    prop = Dict("spatialorder" => ["x", "y"], "pixelspacing" => [1,1])
    cs = getimagecolorspace(wand)
    if imtype == "GrayscaleType" || imtype == "GrayscaleMatteType"
        cs = "Gray"
    end
    prop["IMcs"] = cs

    depth = getimagechanneldepth(wand, DefaultChannels)
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
    exportimagepixels!(buf, wand, cs, channelorder)
    if n > 1
        prop["timedim"] = ndims(buf)
    end
    ImageIO.Image(buf, prop)
end

end
