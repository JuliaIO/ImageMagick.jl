__precompile__()

module ImageMagick

using FixedPointNumbers, ColorTypes, Images
using FileIO: DataFormat, @format_str, Stream, File, filename, stream
using Compat

@compat Color1{T}           = Color{T,1}
@compat Color2{T,C<:Color1} = TransparentColor{C,T,2}
@compat Color3{T}           = Color{T,3}
@compat Color4{T,C<:Color3} = TransparentColor{C,T,4}

@compat AbstractGray{T}     = Color{T,1}

export readblob, image2wand, magickinfo

include("libmagickwand.jl")

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

const ufixedtype = Dict(10=>N6f10, 12=>N4f12, 14=>N2f14, 16=>N0f16)

readblob(data::Vector{UInt8}) = load_(data)

function load_(file::Union{AbstractString,IO,Vector{UInt8}}; ImageType=Array, extraprop="", extrapropertynames=nothing)
    if ImageType != Array
        error("this function now returns an Array, do not use ImageType keyword.")
    end
    if extraprop != "" || extrapropertynames != nothing
        error("keywords \"extraprop\" and \"extrapropertynames\" no longer work, use magickinfo instead")
    end
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
        T = Normed{UInt8,8}     # otherwise use 8 fractional bits
    elseif depth <= 16
        T = Normed{UInt16,evendepth}
    else
        warn("some versions of ImageMagick give spurious low-order bits for 32-bit TIFFs")
        T = Normed{UInt32,evendepth}
    end

    channelorder = cs
    if havealpha
        if channelorder == "sRGB" || channelorder == "RGB"
            T, channelorder = RGBA{T}, "RGBA"
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
    buf = Array{T}(sz)
    exportimagepixels!(rawview(channelview(buf)), wand, cs, channelorder)

    orient = getimageproperty(wand, "exif:Orientation", false)
    orientation_dict[orient](buf)
end


function save_(filename::AbstractString, img, permute_horizontal=true; mapi = identity, quality = nothing, kwargs...)
    wand = image2wand(img, mapi, quality, permute_horizontal; kwargs...)
    writeimage(wand, filename)
end

# This differs from `save_` for files because this is primarily used
# by IJulia, and we want to restrict large images to make display faster.
function save_(s::Stream, img, permute_horizontal=true; mapi = clamp01nan, quality = nothing)
    wand = image2wand(img, mapi, quality, permute_horizontal)
    blob = getblob(wand, formatstring(s))
    write(stream(s), blob)
end

function image2wand(img, mapi=identity, quality=nothing, permute_horizontal=true; kwargs...)
    local imgw
    try
        imgw = map(x->mapIM(mapi(x)), img)
    catch
        warn("Mapping to the storage type failed; perhaps your data had out-of-range values?\nTry `map(clamp01nan, img)` to clamp values to a valid range.")
        rethrow()
    end
    permute_horizontal && (imgw = permutedims_horizontal(imgw))
    if ndims(imgw) > 3
        error("At most 3 dimensions are supported")
    end
    wand = MagickWand()
    T = eltype(imgw)
    channelorder = T<:Real ? "Gray" : ColorTypes.colorant_string(T)
    if T <: Union{RGB,RGBA,ARGB,BGRA,ABGR}
        cs = libversion > v"6.7.5" ? "sRGB" : "RGB"
    else
        cs = channelorder
    end
    if channelorder == "Gray"
        channelorder = "I"
    elseif channelorder == "GrayA"
        channelorder = "IA"
    elseif channelorder == "AGray"
        channelorder = "AI"
    end
    tmp = to_explicit(to_contiguous(imgw))
    constituteimage(tmp, wand, cs, channelorder)
    if quality != nothing
        setimagecompressionquality(wand, quality)
    end
    resetiterator(wand)
    setproperties!(wand; kwargs...)
    wand
end

formatstring{S}(s::Stream{DataFormat{S}}) = string(S)

function magickinfo(file::Union{AbstractString,IO})
    wand = MagickWand()
    readimage(wand, file)
    resetiterator(wand)
    getimageproperties(wand, "*")
end

function magickinfo(file::Union{AbstractString,IO}, properties::Union{Tuple,AbstractVector})
    wand = MagickWand()
    readimage(wand, file)
    resetiterator(wand)

    props = Dict{String,Any}()
    for p in properties
        props[p] = getimageproperty(wand, p)
    end
    props
end
magickinfo(file::Union{AbstractString,IO}, properties...) = magickinfo(file, properties)

function setproperties!(wand; fps=nothing)
    if fps != nothing
        setimagedelay(wand, fps)
    end
    wand
end

# ImageMagick element-mapping function. Converts to RGB/RGBA and uses
# N0f8 "inner" element type.
mapIM(c::Color1) = mapIM(convert(Gray, c))
mapIM{T}(c::Gray{T}) = convert(Gray{N0f8}, c)
mapIM{T<:Normed}(c::Gray{T}) = c

mapIM(c::Color2) = mapIM(convert(GrayA, c))
mapIM{T}(c::GrayA{T}) = convert(GrayA{N0f8}, c)
mapIM{T<:Normed}(c::GrayA{T}) = c

mapIM(c::Color3) = mapIM(convert(RGB, c))
mapIM{T}(c::RGB{T}) = convert(RGB{N0f8}, c)
mapIM{T<:Normed}(c::RGB{T}) = c

mapIM(c::Color4) = mapIM(convert(RGBA, c))
mapIM{T}(c::RGBA{T}) = convert(RGBA{N0f8}, c)
mapIM{T<:Normed}(c::RGBA{T}) = c

mapIM(x::UInt8) = reinterpret(N0f8, x)
mapIM(x::Bool) = convert(N0f8, x)
mapIM(x::AbstractFloat) = convert(N0f8, x)
mapIM(x::Normed) = x

# Make the data contiguous in memory, this is necessary for
# imagemagick since it doesn't handle stride.
to_contiguous(A::Array) = A
to_contiguous(A::AbstractArray) = Compat.collect(A)
to_contiguous(A::BitArray) = convert(Array{N0f8}, A)
to_contiguous(A::ColorView) = to_contiguous(channelview(A))

to_explicit{C<:Colorant}(A::Array{C}) = to_explicit(channelview(A))
to_explicit{T}(A::ChannelView{T}) = to_explicit(copy!(Array{T}(size(A)), A))
to_explicit{T<:Normed}(A::Array{T}) = rawview(A)
to_explicit{T<:AbstractFloat}(A::Array{T}) = to_explicit(convert(Array{N0f8}, A))

permutedims_horizontal(img::AbstractVector) = img
function permutedims_horizontal(img)
    # Vertical-major is hard-coded here
    p = [2;1;3:ndims(img)]
    permutedims(img, p)
end

end # module
