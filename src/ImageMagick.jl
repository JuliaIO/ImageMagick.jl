module ImageMagick

using FileIO: DataFormat, @format_str, Stream, File, filename, stream
using InteractiveUtils: subtypes
using ImageCore
using ImageMagick_jll
using Base: convert

Color1{T}           = Color{T,1}
Color2{T,C<:Color1} = TransparentColor{C,T,2}
Color3{T}           = Color{T,3}
Color4{T,C<:Color3} = TransparentColor{C,T,4}

AbstractGray{T}     = Color{T,1}

export readblob, image2wand, magickinfo

include("libmagickwand.jl")

# Image / Video formats

const image_formats = [
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

"""
    metadata(file) -> tuple of dimensions

The returned value is (X,Y[,Z]), not (R,C), so the first two dimensions
of the corresponding Array returned by `load` are reversed.
"""
function metadata(filename::AbstractString)
    wand = MagickWand()
    readimage(wand, filename)
    sz, T, _, _ = _metadata(wand)
    return sz, T
end

metadata(imagefile::File{T}) where {T <: DataFormat} = metadata(filename(imagefile))

function _metadata(wand)
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
        if cs == "Gray"
            cdepth = getimagechanneldepth(wand, GrayChannel)
            if n > 1
                for k = 1:n  # while it might seem that this should be 2:n, that doesn't work...
                    nextimage(wand)
                    cdepth = max(cdepth, getimagechanneldepth(wand, GrayChannel))
                end
                resetiterator(wand)
            end
            T = cdepth == 1 ? Bool : N0f8
        else
            T = N0f8     # otherwise use 8 fractional bits
        end
    elseif depth <= 16
        T = Normed{UInt16,evendepth}
    else
        @warn "some versions of ImageMagick give spurious low-order bits for 32-bit TIFFs" maxlog=1
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
    sz, T, cs, channelorder
end

load(@nospecialize(imagefile::File{<:DataFormat}), @nospecialize(args...); key_args...) = load_(filename(imagefile), args...; key_args...)
load(filename::AbstractString, @nospecialize(args...); key_args...) = load_(filename, args...; key_args...)
save(@nospecialize(imagefile::File{<:DataFormat}), @nospecialize(args...); key_args...) = save_(filename(imagefile), args...; key_args...)
save(filename::AbstractString, @nospecialize(args...); key_args...) = save_(filename, args...; key_args...)

load(@nospecialize(imgstream::Stream{<:DataFormat}), @nospecialize(args...); key_args...) = load_(stream(imgstream), args...; key_args...)
load(imgstream::IO, args...; key_args...) = load_(imgstream, args...; key_args...)
save(@nospecialize(imgstream::Stream{<:DataFormat}), args...; key_args...) = save_(imgstream, args...; key_args...)

const ufixedtype = Dict(10=>N6f10, 12=>N4f12, 14=>N2f14, 16=>N0f16)

readblob(data::Vector{UInt8}) = load_(data)

function load_(
    file::Union{AbstractString,IO,Vector{UInt8}}, permute_horizontal::Bool=true;
    ImageType=Array, extraprop="", extrapropertynames=nothing, view::Bool=false,
    wand::MagickWand=MagickWand(), dpi::Union{Nothing,Real}=nothing,
)
    if ImageType != Array
        error("this function now returns an Array, do not use ImageType keyword.")
    end
    if extraprop != "" || extrapropertynames != nothing
        error("keywords \"extraprop\" and \"extrapropertynames\" no longer work, use magickinfo instead")
    end
    if dpi !== nothing
        setresolution(wand, dpi, dpi)
    end
    readimage(wand, file)
    resetiterator(wand)

    sz, T, cs, channelorder = _metadata(wand)

    # Allocate the buffer and get the pixel data
    buf = Array{T}(undef, sz)
    exportimagepixels!(rawview(channelview(buf)), wand, cs, channelorder)

    orient = getimageproperty(wand, "exif:Orientation", false)
    default = (A,ph) -> ph ? vertical_major(A) : identity(A)
    oriented_buf = get(orientation_dict, orient, default)(buf, permute_horizontal)
    view ? oriented_buf : collect(oriented_buf)
end


function save_(filename::AbstractString, @nospecialize(img), permute_horizontal=true; mapi = identity, quality = nothing, kwargs...)
    wand = image2wand(img, mapi, quality, permute_horizontal; kwargs...)
    writeimage(wand, filename)
end

# This differs from `save_` for files because this is primarily used
# by IJulia, and we want to restrict large images to make display faster.
function save_(s::Stream, img, permute_horizontal=true; mapi = clamp01nan, quality = nothing, kwargs...)
    wand = image2wand(img, mapi, quality, permute_horizontal; kwargs...)
    blob = getblob(wand, formatstring(s))
    write(stream(s), blob)
end

function image2wand(@nospecialize(img), mapi=identity, quality=nothing, permute_horizontal=true; kwargs...)
    local imgw
    try
        imgw = map(x->mapIM(mapi(x)), img)
    catch
        @warn "Mapping to the storage type failed; perhaps your data had out-of-range values?\nTry `map(clamp01nan, img)` to clamp values to a valid range."
        rethrow()
    end
    permute_horizontal && (imgw = collect(vertical_major(imgw)))
    if ndims(imgw) > 3
        error("At most 3 dimensions are supported")
    end
    wand = MagickWand()
    T = eltype(imgw)
    channelorder = T<:Real ? "Gray" : ColorTypes.colorant_string(T)
    if T <: Union{RGB,RGBA,ARGB,BGRA,ABGR}
        # For imagemagick versions <= v6.7.5, this should be "RGB",
        # but since we ship our own version we always use "sRGB"
        cs = "sRGB"
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

formatstring(s::Stream{DataFormat{S}}) where {S} = string(S)

@doc raw"""
    magickinfo(file::Union{AbstractString,IO})

Reads an image `file` and returns an array of strings describing the property data in the image file.

# Examples
```julia-repl
julia> p = magickinfo("Image.jpeg")
63-element Array{String,1}:
 "date:create"
 "date:modify"
 "exif:ApertureValue"
 "exif:BrightnessValue"
 "exif:ColorSpace"
 "exif:ComponentsConfiguration"
 "exif:DateTime"
 "exif:DateTimeDigitized"
 "exif:DateTimeOriginal"
 "exif:ExifImageLength"
 "exif:ExifImageWidth"
 "exif:ExifOffset"
 "exif:ExifVersion"
 ⋮
 "exif:thumbnail:JPEGInterchangeFormat"
 "exif:thumbnail:JPEGInterchangeFormatLength"
 "exif:thumbnail:ResolutionUnit"
 "exif:thumbnail:XResolution"
 "exif:thumbnail:YResolution"
 "exif:WhiteBalance"
 "exif:XResolution"
 "exif:YCbCrPositioning"
 "exif:YResolution"
 "jpeg:colorspace"
 "jpeg:sampling-factor"
 "unknown"a
```
"""
function magickinfo(file::Union{AbstractString,IO})
    wand = MagickWand()
    readimage(wand, file)
    resetiterator(wand)
    getimageproperties(wand, "*")
end

@doc raw"""
    magickinfo(file::Union{AbstractString,IO}, properties::Union{Tuple,AbstractVector})

Reads an image `file` and returns a Dict containing the values for the requested `properties`.

# Examples
```julia-repl
julia> magickinfo("IMG_6477.jpeg",
           ("exif:DateTime","exif:GPSLatitude","exif:GPSLatitudeRef",
            "exif:GPSLongitude","exif:GPSLongitudeRef","exif:GPSAltitude"))
Dict{String,Any} with 6 entries:
  "exif:GPSLongitudeRef" => "W"
  "exif:GPSLatitude"     => "44/1, 22/1, 2326/100"
  "exif:GPSLatitudeRef"  => "N"
  "exif:GPSLongitude"    => "71/1, 13/1, 5301/100"
  "exif:DateTime"        => "2020:01:22 13:17:41"
  "exif:GPSAltitude"     => "261189/757"
```
"""
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
mapIM(c::Gray{T}) where {T} = convert(Gray{N0f8}, c)
mapIM(c::Gray{T}) where {T<:Normed} = c

mapIM(c::Color2) = mapIM(convert(GrayA, c))
mapIM(c::GrayA{T}) where {T} = convert(GrayA{N0f8}, c)
mapIM(c::GrayA{T}) where {T<:Normed} = c

mapIM(c::Color3) = mapIM(convert(RGB, c))
mapIM(c::RGB{T}) where {T} = convert(RGB{N0f8}, c)
mapIM(c::RGB{T}) where {T<:Normed} = c

mapIM(c::Color4) = mapIM(convert(RGBA, c))
mapIM(c::RGBA{T}) where {T} = convert(RGBA{N0f8}, c)
mapIM(c::RGBA{T}) where {T<:Normed} = c

mapIM(x::UInt8) = reinterpret(N0f8, x)
mapIM(x::UInt16) = reinterpret(N0f16, x)
mapIM(x::UInt32) = reinterpret(N0f32, x)
mapIM(x::Bool) = x
mapIM(x::AbstractFloat) = convert(N0f8, x)
mapIM(x::Normed) = x

# Make the data contiguous in memory, this is necessary for
# imagemagick since it doesn't handle stride.
to_contiguous(A::Array) = A
to_contiguous(A::AbstractArray) = collect(A)
to_contiguous(A::BitArray) = convert(Array{Bool}, A)
if isdefined(ImageCore, :ColorView)
    to_contiguous(A::ColorView) = to_contiguous(channelview(A))
end

to_explicit(A::Array{C}) where {C<:Colorant} = to_explicit(channelview(A))
function to_explicit(A::AbstractArray)
    As = similar(A)
    As .= A
    to_explicit(As)
end
to_explicit(A::Array{Bool}) = A
to_explicit(A::Array{T}) where {T<:Normed} = rawview(A)
to_explicit(A::Array{T}) where {T<:AbstractFloat} = to_explicit(convert(Array{N0f8}, A))

include("precompile.jl")
_precompile_()

end # module
