###
### writemime
###
# only mime writeable to PNG if 2D (used by IJulia for example)
mimewritable(::MIME"image/png", img::AbstractImage) = sdims(img) == 2 && timedim(img) == 0


function Base.writemime(io::IO, ::MIME"image/png", img::AbstractImage; mapi=mapinfo_writemime(img), minpixels=10^4, maxpixels=10^6)
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

Base.writemime(stream::IO, mime::MIME"image/png", img::AbstractImageIndexed; kwargs...) = (println(kwargs);
    writemime(stream, mime, convert(Image, img); kwargs...))


function mapinfo_writemime(img; maxpixels=10^6)
    if length(img) <= maxpixels
        return mapinfo_writemime_(img)
    end
    mapinfo_writemime_restricted(img)
end

to_native_color{T<:Colorant}(::Type{T})         = base_color_type(T){Ufixed8}
to_native_color{T<:Color}(::Type{T})            = RGB{Ufixed8}
to_native_color{T<:TransparentColor}(::Type{T}) = RGBA{Ufixed8}

mapinfo_writemime_{T <:Colorant}(img::AbstractImage{T})          = Images.mapinfo(to_native_color(T), img)

mapinfo_writemime_restricted{T<:Colorant}(img::AbstractImage{T}) = ClampMinMax(to_native_color(T), 0.0, 1.0)
mapinfo_writemime_restricted(img::AbstractImage)                 = Images.mapinfo(Ufixed8, img)
