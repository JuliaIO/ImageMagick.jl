VERSION >= v"0.4.0-dev+6521" && __precompile__(true)
module ImageMagick

using FixedPointNumbers, ColorTypes, Compat, Images, ColorVectorSpace
import FileIO: @format_str, File, Stream, filename, stream

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

for format in image_formats
    eval(quote
        load(image::File{$format}, args...; key_args...) = load_(filename(image), args...; key_args...)
        save(image::File{$format}, args...; key_args...) = save_(filename(image), args...; key_args...)

        load(image::Stream{$format}, args...; key_args...) = load_(stream(image), args...; key_args...)
        save(image::Stream{$format}, args...; key_args...) = save_(stream(image), args...; key_args...)
    end)
end

const ufixedtype = @compat Dict(10=>Ufixed10, 12=>Ufixed12, 14=>Ufixed14, 16=>Ufixed16)


function load_(file::@compat(Union{AbstractString,IO}), ImageType=Image)
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

    prop = Dict{UTF8String, Any}()
    prop["spatialorder"] = ["x", "y"]
    n > 1 && (prop["timedim"] = ndims(buf))
    prop["colorspace"] = cs

    ImageType(buf, prop)
end



save_(file::File; kwargs...) = save_(filename(file); kwargs...)
save_(s::Stream, img; kwargs...) = save_(stream(s), img; kwargs...)


function save_(filename::AbstractString, img, permute_horizontal=false; mapi = mapinfo(img), quality = nothing)
    wand = image2wand(img, mapi, quality, permute_horizontal)
    writeimage(wand, filename)
end

function image2wand(img, mapi, quality, permute_horizontal=false)
    imgw = map(mapi, img)
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
        if in(cs, ("RGB", "RGBA", "ARGB", "BGRA"))
            cs = libversion > v"6.7.5" ? "sRGB" : "RGB"
        end
    end
    channelorder = colorspace(imgw)
    if channelorder == "Gray"
        channelorder = "I"
    elseif channelorder == "GrayA"
        channelorder = "IA"
    end
    tmp = to_explicit(to_contiguous(data(imgw)))
    constituteimage(tmp, wand, cs, channelorder)
    if quality != nothing
        setimagecompressionquality(wand, quality)
    end
    resetiterator(wand)
    wand
end
# ImageMagick mapinfo client. Converts to RGB and uses Ufixed.
mapinfo{T<:Ufixed}(img::AbstractArray{T}) = MapNone{T}()
mapinfo{T<:AbstractFloat}(img::AbstractArray{T}) = MapNone{Ufixed8}()
for ACV in (Color, AbstractRGB)
    for CV in subtypes(ACV)
        (length(CV.parameters) == 1 && !(CV.abstract)) || continue
        CVnew = CV<:AbstractGray ? Gray : RGB
        @eval mapinfo{T<:Ufixed}(img::AbstractArray{$CV{T}}) = MapNone{$CVnew{T}}()
        @eval mapinfo{CV<:$CV}(img::AbstractArray{CV}) = MapNone{$CVnew{Ufixed8}}()
        CVnew = CV<:AbstractGray ? Gray : BGR
        AC, CA       = alphacolor(CV), coloralpha(CV)
        ACnew, CAnew = alphacolor(CVnew), coloralpha(CVnew)
        @eval begin
            mapinfo{T<:Ufixed}(img::AbstractArray{$AC{T}}) = MapNone{$ACnew{T}}()
            mapinfo{P<:$AC}(img::AbstractArray{P}) = MapNone{$ACnew{Ufixed8}}()
            mapinfo{T<:Ufixed}(img::AbstractArray{$CA{T}}) = MapNone{$CAnew{T}}()
            mapinfo{P<:$CA}(img::AbstractArray{P}) = MapNone{$CAnew{Ufixed8}}()
        end
    end
end
mapinfo(img::AbstractArray{RGB24}) = MapNone{RGB{Ufixed8}}()
mapinfo(img::AbstractArray{ARGB32}) = MapNone{BGRA{Ufixed8}}()


# Make the data contiguous in memory, this is necessary for
# imagemagick since it doesn't handle stride.
to_contiguous(A::AbstractArray) = A
to_contiguous(A::SubArray) = copy(A)

to_explicit(A::AbstractArray) = A
to_explicit{T<:Ufixed}(A::AbstractArray{T}) = reinterpret(FixedPointNumbers.rawtype(T), A)
to_explicit{T<:Ufixed}(A::AbstractArray{RGB{T}}) = reinterpret(FixedPointNumbers.rawtype(T), A, tuple(3, size(A)...))
to_explicit{T<:AbstractFloat}(A::AbstractArray{RGB{T}}) = to_explicit(map(ClampMinMax(RGB{Ufixed8}, zero(RGB{T}), one(RGB{T})), A))
to_explicit{T<:Ufixed}(A::AbstractArray{Gray{T}}) = reinterpret(FixedPointNumbers.rawtype(T), A, size(A))
to_explicit{T<:AbstractFloat}(A::AbstractArray{Gray{T}}) = to_explicit(map(ClampMinMax(Gray{Ufixed8}, zero(Gray{T}), one(Gray{T})), A))

to_explicit{T<:Ufixed}(A::AbstractArray{GrayA{T}}) = reinterpret(FixedPointNumbers.rawtype(T), A, size(A))
to_explicit{T<:AbstractFloat}(A::AbstractArray{GrayA{T}}) = to_explicit(map(ClampMinMax(GrayA{Ufixed8}, zero(GrayA{T}), one(GrayA{T})), A))

to_explicit{T<:Ufixed}(A::AbstractArray{BGRA{T}}) = reinterpret(FixedPointNumbers.rawtype(T), A, tuple(4, size(A)...))
to_explicit{T<:AbstractFloat}(A::AbstractArray{BGRA{T}}) = to_explicit(map(ClampMinMax(BGRA{Ufixed8}, zero(BGRA{T}), one(BGRA{T})), A))
to_explicit{T<:Ufixed}(A::AbstractArray{RGBA{T}}) = reinterpret(FixedPointNumbers.rawtype(T), A, tuple(4, size(A)...))
to_explicit{T<:AbstractFloat}(A::AbstractArray{RGBA{T}}) = to_explicit(map(ClampMinMax(RGBA{Ufixed8}, zero(RGBA{T}), one(RGBA{T})), A))



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


###
### writemime
###

function Base.writemime(s::Stream{format"ImageMagick"}, ::MIME"image/png", img::AbstractImage; mapi=mapinfo_writemime(img), minpixels=10^4, maxpixels=10^6)
    io = stream(s)
    assert2d(img)
    A = data(img)
    nc = ncolorelem(img)
    npix = length(A)/nc
    while npix > maxpixels
        A = restrict(A, coords_spatial(img))
        npix = length(A)/nc
    end
    if npix < minpixels
        fac = ceil(Int, sqrt(minpixels/npix))
        r = ones(Int, ndims(img))
        r[coords_spatial(img)] = fac
        A = repeat(A, inner=r)
    end
    wand = image2wand(shareproperties(img, A), mapi, nothing)
    blob = getblob(wand, "png")
    write(io, blob)
end

# This may get called if the FileIO callback hasn't been compiled-in
Base.writemime(io::IO, mime::MIME"image/png", img::AbstractImage; kwargs...) =
   writemime(Stream(format"ImageMagick", io), mime, img; kwargs...)

function mapinfo_writemime(img; maxpixels=10^6)
    if length(img) <= maxpixels
        return mapinfo_writemime_(img)
    end
    mapinfo_writemime_restricted(img)
end
mapinfo_writemime_{T}(img::AbstractImage{Gray{T}}) = Images.mapinfo(Gray{Ufixed8},img)
mapinfo_writemime_{C<:Color}(img::AbstractImage{C}) = Images.mapinfo(RGB{Ufixed8},img)
mapinfo_writemime_{AC<:GrayA}(img::AbstractImage{AC}) = Images.mapinfo(GrayA{Ufixed8},img)
mapinfo_writemime_{AC<:TransparentColor}(img::AbstractImage{AC}) = Images.mapinfo(RGBA{Ufixed8},img)
mapinfo_writemime_(img::AbstractImage) = Images.mapinfo(Ufixed8,img)

mapinfo_writemime_restricted{T}(img::AbstractImage{Gray{T}}) = ClampMinMax(Gray{Ufixed8},0.0,1.0)
mapinfo_writemime_restricted{C<:Color}(img::AbstractImage{C}) = ClampMinMax(RGB{Ufixed8},0.0,1.0)
mapinfo_writemime_restricted{AC<:GrayA}(img::AbstractImage{AC}) = ClampMinMax(GrayA{Ufixed8},0.0,1.0)
mapinfo_writemime_restricted{AC<:TransparentColor}(img::AbstractImage{AC}) = ClampMinMax(RGBA{Ufixed8},0.0,1.0)
mapinfo_writemime_restricted(img::AbstractImage) = Images.mapinfo(Ufixed8,img)



function load(s::Stream{format"PGMBinary"})
    io = stream(s)
    w, h = parse_netpbm_size(io)
    maxval = parse_netpbm_maxval(io)
    local dat
    if maxval <= 255
        dat = read(io, Ufixed8, w, h)
    elseif maxval <= typemax(UInt16)
        datraw = Array(UInt16, w, h)
        if !is_little_endian
            for indx = 1:w*h
                datraw[indx] = read(io, UInt16)
            end
        else
            for indx = 1:w*h
                datraw[indx] = bswap(read(io, UInt16))
            end
        end
        # Determine the appropriate Ufixed type
        T = ufixedtype[ceil(Int, log2(maxval)/2)<<1]
        dat = reinterpret(RGB{T}, datraw, (w, h))
    else
        error("Image file may be corrupt. Are there really more than 16 bits in this image?")
    end
    T = eltype(dat)
    Image(dat, @compat Dict("colorspace" => "Gray", "spatialorder" => ["x", "y"], "pixelspacing" => [1,1]))
end


function load(s::Stream{format"PBMBinary"})
    io = stream(s)
    w, h = parse_netpbm_size(io)
    dat = BitArray(w, h)
    nbytes_per_row = ceil(Int, w/8)
    for irow = 1:h, j = 1:nbytes_per_row
        tmp = read(io, UInt8)
        offset = (j-1)*8
        for k = 1:min(8, w-offset)
            dat[offset+k, irow] = (tmp>>>(8-k))&0x01
        end
    end
    Image(dat, @compat Dict("spatialorder" => ["x", "y"], "pixelspacing" => [1,1]))
end

function save(filename::File{format"PPMBinary"}, img)
    open(filename, "w") do s
        write(s, "P6\n")
        write(s, "# ppm file written by Julia\n")
        save(s, img)
    end
end

pnmmax{T<:AbstractFloat}(::Type{T}) = 255
pnmmax{T<:Ufixed}(::Type{T}) = reinterpret(FixedPointNumbers.rawtype(T), one(T))
pnmmax{T<:Unsigned}(::Type{T}) = typemax(T)

function save{T<:Color}(s::Stream{format"PPMBinary"}, img::AbstractArray{T}, mapi = mapinfo(img))
    w, h = widthheight(img)
    TE = eltype(T)
    mx = pnmmax(TE)
    write(s, "$w $h\n$mx\n")
    p = permutation_horizontal(img)
    writepermuted(s, img, mapi, p; gray2color = T <: AbstractGray)
end

function save{T}(s::Stream{format"PPMBinary"}, img::AbstractArray{T}, mapi = mapinfo(ImageMagick, img))
    io = stream(s)
    w, h = widthheight(img)
    cs = colorspace(img)
    in(cs, ("RGB", "Gray")) || error("colorspace $cs not supported")
    mx = pnmmax(T)
    write(io, "$w $h\n$mx\n")
    p = permutation_horizontal(img)
    writepermuted(io, img, mapi, p; gray2color = cs == "Gray")
end




end # module
