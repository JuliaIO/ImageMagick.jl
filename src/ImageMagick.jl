__precompile__(true)
module ImageMagick

using Compat
import Compat.String

using FixedPointNumbers, ColorTypes, Images, ColorVectorSpace
using FileIO: DataFormat, @format_str, Stream, File, filename, stream

export readblob
export image2wand

include("libmagickwand.jl")


typealias AbstractGray{T} Color{T, 1}

const is_little_endian = ENDIAN_BOM == 0x04030201

# Image / Video formats

image_formats = [
    format"BMP",
    format"AVI",
    format"CRW",
    format"CUR",
    format"DCX",
    format"DOT",
    format"EPS",
    format"GIF",
    format"HDR",
    format"ICO",
    format"INFO",
    format"JP2",
    format"JPEG",
    format"PCX",
    format"PDB",
    format"PDF",
    format"PGM",
    format"PNG",
    format"PSD",
    format"RGB",
    format"TIFF",
    format"WMF",
    format"WPG",
    format"TGA"
]

load{T <: DataFormat}(imagefile::File{T}, args...; key_args...) = load_(filename(imagefile), args...; key_args...)
load(filename::AbstractString, args...; key_args...) = load_(filename, args...; key_args...)
save{T <: DataFormat}(imagefile::File{T}, args...; key_args...) = save_(filename(imagefile), args...; key_args...)
save(filename::AbstractString, args...; key_args...) = save_(filename, args...; key_args...)

load{T <: DataFormat}(imgstream::Stream{T}, args...; key_args...) = load_(stream(imgstream), args...; key_args...)
load(imgstream::IO, args...; key_args...) = load_(imgstream, args...; key_args...)
save{T <: DataFormat}(imgstream::Stream{T}, args...; key_args...) = save_(imgstream, args...; key_args...)

readblob(data::Vector{UInt8}) = load_(data)

function load_(file::Union{AbstractString,IO,Vector{UInt8}})
    # TODO: deprecate ImageType kw, extraprop, extrapropertynames
    wand = MagickWand()
    readimage(wand, file)
    resetiterator(wand)

    # Determine what we need to know about the image format
    sz = size(wand)
    n = getnumberimages(wand)
    if n > 1
        sz = tuple(sz..., n)
    end

    imtype      = getimagetype(wand)
    havealpha   = getimagealphachannel(wand)
    cs          = getimagecolorspace(wand)
    if imtype == "GrayscaleType" || imtype == "GrayscaleMatteType"
        cs = "Gray"
    end

    depth = getimagedepth(wand)
    # use an even # of fractional bits for depth>8 (see issue 242#issuecomment-68845157)
    evendepth = ((depth+1)>>1)<<1
    if depth <= 8
        T = UFixed{UInt8,8}     # otherwise use 8 fractional bits
    elseif depth <= 16
        T = UFixed{UInt16,evendepth}
    else
        warn("some versions of ImageMagick give spurious low-order bits for 32-bit TIFFs")
        T = UFixed{UInt32,evendepth}
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
            T, channelorder = GrayA{T}, "IA"
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

    prop = Dict{Compat.UTF8String, Any}()
    orient = getimageproperty(wand, "exif:Orientation", false)
    img = orientation_dict[orient](buf)

    img
end



function save_(filename::AbstractString, img, permute_horizontal=true; mapi = mapinfo(img), quality = nothing)
    wand = image2wand(img, mapi, quality, permute_horizontal)
    writeimage(wand, filename)
end

# This differs from `save_` for files because this is primarily used
# by IJulia, and we want to restrict large images to make display faster.
function save_(s::Stream, img, permute_horizontal=true; mapi = Images.mapinfo_writemime(img), quality = nothing)
    wand = image2wand(img, mapi, quality, permute_horizontal)
    blob = getblob(wand, formatstring(s))
    write(stream(s), blob)
end

function image2wand(img, mapi, quality, permute_horizontal=true)
    local imgw
    try
        imgw = map(mapi, img)
    catch
        warn("Mapping to the storage type failed; perhaps your data had out-of-range values?\nTry `map(Images.Clamp01NaN(img), img)` to clamp values to a valid range.")
        rethrow()
    end
    permute_horizontal && (imgw = permutedims_horizontal(imgw))
    have_color = colordim(imgw)!=0
    if ndims(imgw) > 3+have_color
        error("At most 3 dimensions are supported")
    end
    wand = MagickWand()
    if haskey(img, "colorspace")
        cs = img["colorspace"]
    else
        cs = colorspace(imgw)
    end
    if in(cs, ("RGB", "RGBA", "ARGB", "BGRA", "ABGR"))
        cs = libversion > v"6.7.5" ? "sRGB" : "RGB"
    end
    channelorder = colorspace(imgw)
    if channelorder == "Gray"
        channelorder = "I"
    elseif channelorder == "GrayA"
        channelorder = "IA"
    elseif channelorder == "AGray"
        channelorder = "AI"
    end
    tmp = to_explicit(to_contiguous(data(imgw)))
    constituteimage(tmp, wand, cs, channelorder)
    if quality != nothing
        setimagecompressionquality(wand, quality)
    end
    resetiterator(wand)
    wand
end

formatstring{S}(s::Stream{DataFormat{S}}) = string(S)

# ImageMagick mapinfo client. Converts to RGB and uses UFixed.
mapinfo(img::AbstractArray{Bool}) = MapNone{UFixed8}()
mapinfo{T<:UFixed}(img::AbstractArray{T}) = MapNone{T}()
mapinfo{T<:AbstractFloat}(img::AbstractArray{T}) = MapNone{UFixed8}()
let handled = Set()
for ACV in (Color, AbstractRGB)
    for CV in subtypes(ACV)
        (length(CV.parameters) == 1 && !(CV.abstract)) || continue
        CVnew = CV<:AbstractGray ? Gray : RGB
        @eval mapinfo{T<:UFixed}(img::AbstractArray{$CV{T}}) = MapNone{$CVnew{T}}()
        @eval mapinfo{CV<:$CV}(img::AbstractArray{CV}) = MapNone{$CVnew{UFixed8}}()
        CVnew = CV<:AbstractGray ? Gray : BGR
        AC, CA       = alphacolor(CV), coloralpha(CV)
        if AC in handled
            continue
        end
        push!(handled, AC)
        ACnew, CAnew = alphacolor(CVnew), coloralpha(CVnew)
        @eval begin
            mapinfo{T<:UFixed}(img::AbstractArray{$AC{T}}) = MapNone{$ACnew{T}}()
            mapinfo{P<:$AC}(img::AbstractArray{P}) = MapNone{$ACnew{UFixed8}}()
            mapinfo{T<:UFixed}(img::AbstractArray{$CA{T}}) = MapNone{$CAnew{T}}()
            mapinfo{P<:$CA}(img::AbstractArray{P}) = MapNone{$CAnew{UFixed8}}()
        end
    end
end
end
mapinfo(img::AbstractArray{RGB24}) = MapNone{RGB{UFixed8}}()
mapinfo(img::AbstractArray{ARGB32}) = MapNone{BGRA{UFixed8}}()


# Make the data contiguous in memory, this is necessary for
# imagemagick since it doesn't handle stride.
to_contiguous(A::Array) = A
to_contiguous(A::AbstractArray) = copy(A)
to_contiguous(A::SubArray) = copy(A)

to_explicit(A::Image) = to_explicit(data(A))
to_explicit(A::AbstractArray) = to_explicit(copy(A))

to_explicit{T<:UFixed}(A::Array{T}) = reinterpret(FixedPointNumbers.rawtype(T), A)

to_explicit{T<:UFixed}(A::Array{RGB{T}}) = reinterpret(FixedPointNumbers.rawtype(T), A, tuple(3, size(A)...))
to_explicit{T<:AbstractFloat}(A::Array{RGB{T}}) = to_explicit(map(ClampMinMax(RGB{UFixed8}, zero(RGB{T}), one(RGB{T})), A))
to_explicit{T<:UFixed}(A::Array{Gray{T}}) = reinterpret(FixedPointNumbers.rawtype(T), A, size(A))
to_explicit{T<:AbstractFloat}(A::Array{Gray{T}}) = to_explicit(map(ClampMinMax(Gray{UFixed8}, zero(Gray{T}), one(Gray{T})), A))

to_explicit{T<:UFixed}(A::Array{GrayA{T}}) = reinterpret(FixedPointNumbers.rawtype(T), A)
to_explicit{T<:AbstractFloat}(A::Array{GrayA{T}}) = to_explicit(map(ClampMinMax(GrayA{UFixed8}, zero(GrayA{T}), one(GrayA{T})), A))

to_explicit{T<:UFixed}(A::Array{BGRA{T}}) = reinterpret(FixedPointNumbers.rawtype(T), A, tuple(4, size(A)...))
to_explicit{T<:AbstractFloat}(A::Array{BGRA{T}}) = to_explicit(map(ClampMinMax(BGRA{UFixed8}, zero(BGRA{T}), one(BGRA{T})), A))
to_explicit{T<:UFixed}(A::Array{RGBA{T}}) = reinterpret(FixedPointNumbers.rawtype(T), A, tuple(4, size(A)...))
to_explicit{T<:AbstractFloat}(A::Array{RGBA{T}}) = to_explicit(map(ClampMinMax(RGBA{UFixed8}, zero(RGBA{T}), one(RGBA{T})), A))



# Permute to a color, horizontal, vertical, ... storage order (with time always last)
function permutation_horizontal(img)
    cd = colordim(img)
    td = timedim(img)
    p = spatialpermutation(["x", "y"], img)
    if cd != 0
        p[p .>= cd] += 1
        insert!(p, 1, cd)
    end
    if td != 0
        push!(p, td)
    end
    p
end

permutedims_horizontal(img) = permutedims(img, permutation_horizontal(img))

end # module
