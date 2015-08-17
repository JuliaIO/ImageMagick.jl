module ImageMagick

using FixedPointNumbers, ColorTypes, FileIO, Compat

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

include("libmagickwand.jl")

const is_little_endian = ENDIAN_BOM == 0x04030201

load_(file::File) = load_(filename(file))

function load_(file::Union(AbstractString,IO))
    wand = MagickWand()
    readimage(wand, file)
    resetiterator(wand)

    # Determine what we need to know about the image format
    sz = size(wand)
    n = getnumberimages(wand)
    if n > 1
        sz = tuple(sz..., n)
    end

    imtype = getimagetype(wand)
    havealpha = getimagealphachannel(wand)
    cs = getimagecolorspace(wand)
    if imtype == "GrayscaleType" || imtype == "GrayscaleMatteType"
        cs = "Gray"
    end

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
            T, channelorder = TransparentGray{T}, "IA"
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

    buf
end

save_(file::File; kwargs...) = save_(filename(file); kwargs...)

function save_(file::ByteString, img; kwargs...)
    wand = image2wand(img; kwargs...)
    writeimage(wand, file)
end

save_(s::Stream, img; kwargs...) = save_(stream(s), img; kwargs...)

function save_(io::IO, img; fmt="png", kwargs...)
    wand = image2wand(img; kwargs...)
    blob = getblob(wand, fmt)
    write(io, blob)
end

function image2wand(img; cs=colorstring(img), channelorder=colorstring(img), quality=nothing)
    wand = MagickWand()

    if in(cs, ("RGB", "RGBA", "ARGB", "BGRA"))
        cs = libversion > v"6.7.5" ? "sRGB" : "RGB"
    end
    if channelorder == "Gray"
        channelorder = "I"
    elseif channelorder == "TransparentGray"
        channelorder = "IA"
    end
    tmp = to_explicit(to_contiguous(data(img)))
    constituteimage(tmp, wand, cs, channelorder)
    if quality != nothing
        setimagecompressionquality(wand, quality)
    end
    resetiterator(wand)
    wand
end

# Make the data contiguous in memory, this is necessary for
# imagemagick since it doesn't handle stride.
to_contiguous(A::AbstractArray) = A
to_contiguous(A::SubArray) = copy(A)

to_explicit(A::AbstractArray) = A
to_explicit{T<:Ufixed}(A::AbstractArray{T}) = reinterpret(FixedPointNumbers.rawtype(T), A)
to_explicit{T<:Ufixed}(A::AbstractArray{RGB{T}}) = reinterpret(FixedPointNumbers.rawtype(T), A, tuple(3, size(A)...))
to_explicit{T<:FloatingPoint}(A::AbstractArray{RGB{T}}) = to_explicit(map(ClipMinMax(RGB{Ufixed8}, zero(RGB{T}), one(RGB{T})), A))
to_explicit{T<:Ufixed}(A::AbstractArray{Gray{T}}) = reinterpret(FixedPointNumbers.rawtype(T), A, size(A))
to_explicit{T<:FloatingPoint}(A::AbstractArray{Gray{T}}) = to_explicit(map(ClipMinMax(Gray{Ufixed8}, zero(Gray{T}), one(Gray{T})), A))
to_explicit{T<:Ufixed}(A::AbstractArray{TransparentGray{T}}) = reinterpret(FixedPointNumbers.rawtype(T), A, tuple(2, size(A)...))
to_explicit{T<:FloatingPoint}(A::AbstractArray{TransparentGray{T}}) = to_explicit(map(ClipMinMax(TransparentGray{Ufixed8}, zero(TransparentGray{T}), one(TransparentGray{T})), A))
to_explicit{T<:Ufixed}(A::AbstractArray{BGRA{T}}) = reinterpret(FixedPointNumbers.rawtype(T), A, tuple(4, size(A)...))
to_explicit{T<:FloatingPoint}(A::AbstractArray{BGRA{T}}) = to_explicit(map(ClipMinMax(BGRA{Ufixed8}, zero(BGRA{T}), one(BGRA{T})), A))
to_explicit{T<:Ufixed}(A::AbstractArray{RGBA{T}}) = reinterpret(FixedPointNumbers.rawtype(T), A, tuple(4, size(A)...))
to_explicit{T<:FloatingPoint}(A::AbstractArray{RGBA{T}}) = to_explicit(map(ClipMinMax(RGBA{Ufixed8}, zero(RGBA{T}), one(RGBA{T})), A))

end # module
