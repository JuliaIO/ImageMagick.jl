import Base: error, size, PermutedDimsArrays

export MagickWand,
    constituteimage,
    exportimagepixels!,
    getblob,
    getimagealphachannel,
    getimagecolorspace,
    getimagedepth,
    getnumberimages,
    #importimagepixels,
    readimage,
    resetiterator,
    setimagecolorspace,
    setimagecompression,
    setimagecompressionquality,
    setimagedelay,
    setimageformat,
    writeimage

const depsfile = joinpath(dirname(@__DIR__), "deps", "deps.jl")
if isfile(depsfile)
    include(depsfile)
else
    error("ImageMagick not properly installed. Please run Pkg.build(\"ImageMagick\") then restart Julia.")
end

const libmagick = Ref{Ptr{Void}}()

const MagickWandGenesis                = Ref{Ptr{Void}}()
const MagickWandTerminus               = Ref{Ptr{Void}}()
const IsMagickWandInstantiated         = Ref{Ptr{Void}}()
const NewMagickWand                    = Ref{Ptr{Void}}()
const DestroyMagickWand                = Ref{Ptr{Void}}()
const NewPixelWand                     = Ref{Ptr{Void}}()
const DestroyPixelWand                 = Ref{Ptr{Void}}()
const MagickGetException               = Ref{Ptr{Void}}()
const PixelGetException                = Ref{Ptr{Void}}()
const MagickExportImagePixels          = Ref{Ptr{Void}}()
const MagickImportImagePixels          = Ref{Ptr{Void}}()
const MagickConstituteImage            = Ref{Ptr{Void}}()
const MagickSetImageDepth              = Ref{Ptr{Void}}()
const MagickGetImagesBlob              = Ref{Ptr{Void}}()
const MagickPingImage                  = Ref{Ptr{Void}}()
const MagickReadImage                  = Ref{Ptr{Void}}()
const MagickReadImageFile              = Ref{Ptr{Void}}()
const MagickReadImageBlob              = Ref{Ptr{Void}}()
const MagickWriteImages                = Ref{Ptr{Void}}()
const MagickWriteImagesFile            = Ref{Ptr{Void}}()
const MagickGetImageHeight             = Ref{Ptr{Void}}()
const MagickGetImageWidth              = Ref{Ptr{Void}}()
const MagickGetNumberImages            = Ref{Ptr{Void}}()
const MagickNextImage                  = Ref{Ptr{Void}}()
const MagickResetIterator              = Ref{Ptr{Void}}()
const MagickNewImage                   = Ref{Ptr{Void}}()
const MagickGetImageAlphaChannel       = Ref{Ptr{Void}}()
const MagickGetImageProperties         = Ref{Ptr{Void}}()
const MagickGetImageProperty           = Ref{Ptr{Void}}()
const MagickGetImageColors             = Ref{Ptr{Void}}()
const MagickGetImageType               = Ref{Ptr{Void}}()
const MagickSetImageType               = Ref{Ptr{Void}}()
const MagickGetImageColorspace         = Ref{Ptr{Void}}()
const MagickSetImageColorspace         = Ref{Ptr{Void}}()
const MagickSetImageCompression        = Ref{Ptr{Void}}()
const MagickSetImageCompressionQuality = Ref{Ptr{Void}}()
const MagickGetImageTicksPerSecond     = Ref{Ptr{Void}}()
const MagickGetImageDelay              = Ref{Ptr{Void}}()
const MagickSetImageDelay              = Ref{Ptr{Void}}()
const MagickSetImageFormat             = Ref{Ptr{Void}}()
const MagickGetImageDepth              = Ref{Ptr{Void}}()
const MagickGetImageChannelDepth       = Ref{Ptr{Void}}()
const PixelSetColor                    = Ref{Ptr{Void}}()
const MagickRelinquishMemory           = Ref{Ptr{Void}}()
const MagickQueryConfigureOption       = Ref{Ptr{Void}}()
const MagickQueryConfigureOptions      = Ref{Ptr{Void}}()

magickgenesis() = ccall(MagickWandGenesis[], Void, ())
magickterminus() = ccall(MagickWandTerminus[], Void, ())
isinstantiated() = ccall(IsMagickWandInstantiated[], Cint, ()) == 1

loadsym(cfun::Symbol) = Libdl.dlsym(libmagick[], cfun)

getlibversion() = VersionNumber(join(split(queryoption("LIB_VERSION_NUMBER"), ',')[1:3], '.'))

function __init__()
    isdefined(ImageMagick, :initenv) && initenv()

    libmagick[] = Libdl.dlopen(libwand, Libdl.RTLD_GLOBAL)
    MagickWandGenesis[]                = loadsym(:MagickWandGenesis)
    MagickWandTerminus[]               = loadsym(:MagickWandTerminus)    
    NewMagickWand[]                    = loadsym(:NewMagickWand)
    DestroyMagickWand[]                = loadsym(:DestroyMagickWand)
    NewPixelWand[]                     = loadsym(:NewPixelWand)
    DestroyPixelWand[]                 = loadsym(:DestroyPixelWand)
    MagickGetException[]               = loadsym(:MagickGetException)
    PixelGetException[]                = loadsym(:PixelGetException)
    MagickExportImagePixels[]          = loadsym(:MagickExportImagePixels)
    MagickImportImagePixels[]          = loadsym(:MagickImportImagePixels)
    MagickConstituteImage[]            = loadsym(:MagickConstituteImage)
    MagickSetImageDepth[]              = loadsym(:MagickSetImageDepth)
    MagickGetImagesBlob[]              = loadsym(:MagickGetImagesBlob)
    MagickPingImage[]                  = loadsym(:MagickPingImage)
    MagickReadImage[]                  = loadsym(:MagickReadImage)
    MagickReadImageFile[]              = loadsym(:MagickReadImageFile)
    MagickReadImageBlob[]              = loadsym(:MagickReadImageBlob)
    MagickWriteImages[]                = loadsym(:MagickWriteImages)
    MagickWriteImagesFile[]            = loadsym(:MagickWriteImagesFile)
    MagickGetImageHeight[]             = loadsym(:MagickGetImageHeight)
    MagickGetImageWidth[]              = loadsym(:MagickGetImageWidth)
    MagickGetNumberImages[]            = loadsym(:MagickGetNumberImages)
    MagickNextImage[]                  = loadsym(:MagickNextImage)
    MagickResetIterator[]              = loadsym(:MagickResetIterator)
    MagickNewImage[]                   = loadsym(:MagickNewImage)
    MagickGetImageAlphaChannel[]       = loadsym(:MagickGetImageAlphaChannel)
    MagickGetImageProperties[]         = loadsym(:MagickGetImageProperties)
    MagickGetImageProperty[]           = loadsym(:MagickGetImageProperty)
    MagickGetImageColors[]             = loadsym(:MagickGetImageColors)
    MagickGetImageType[]               = loadsym(:MagickGetImageType)
    MagickSetImageType[]               = loadsym(:MagickSetImageType)
    MagickGetImageColorspace[]         = loadsym(:MagickGetImageColorspace)
    MagickSetImageColorspace[]         = loadsym(:MagickSetImageColorspace)
    MagickSetImageCompression[]        = loadsym(:MagickSetImageCompression)
    MagickSetImageCompressionQuality[] = loadsym(:MagickSetImageCompressionQuality)
    MagickGetImageTicksPerSecond[]     = loadsym(:MagickGetImageTicksPerSecond)
    MagickGetImageDelay[]              = loadsym(:MagickGetImageDelay)
    MagickSetImageDelay[]              = loadsym(:MagickSetImageDelay)
    MagickSetImageFormat[]             = loadsym(:MagickSetImageFormat)
    MagickGetImageDepth[]              = loadsym(:MagickGetImageDepth)
    MagickGetImageChannelDepth[]       = loadsym(:MagickGetImageChannelDepth)
    PixelSetColor[]                    = loadsym(:PixelSetColor)
    MagickRelinquishMemory[]           = loadsym(:MagickRelinquishMemory)
    MagickQueryConfigureOptions[]      = loadsym(:MagickQueryConfigureOptions)
    MagickQueryConfigureOption[]       = loadsym(:MagickQueryConfigureOption)
    global libversion = getlibversion()
    IsMagickWandInstantiated[] = libversion < v"6.9" ? loadsym(:IsMagickInstantiated) : loadsym(:IsMagickWandInstantiated)

    if !isinstantiated()
        magickgenesis()
    end
end

# Constants
# Storage types
const CHARPIXEL    = 1
const DOUBLEPIXEL  = 2
const FLOATPIXEL   = 3
const INTEGERPIXEL = 4
const SHORTPIXEL   = 7
const IMStorageTypes = Union{UInt8,UInt16,UInt32,Float32,Float64}
storagetype(::Type{UInt8})   = CHARPIXEL
storagetype(::Type{UInt16})  = SHORTPIXEL
storagetype(::Type{UInt32})  = INTEGERPIXEL
storagetype(::Type{Float32}) = FLOATPIXEL
storagetype(::Type{Float64}) = DOUBLEPIXEL
storagetype{T<:Normed}(::Type{T}) = storagetype(FixedPointNumbers.rawtype(T))
storagetype{CV<:Colorant}(::Type{CV}) = storagetype(eltype(CV))

# Channel types
type ChannelType
    value::UInt32
end
const UndefinedChannel  = ChannelType(0x00000000)
const RedChannel        = ChannelType(0x00000001)
const GrayChannel       = ChannelType(0x00000001)
const CyanChannel       = ChannelType(0x00000001)
const GreenChannel      = ChannelType(0x00000002)
const MagentaChannel    = ChannelType(0x00000002)
const BlueChannel       = ChannelType(0x00000004)
const YellowChannel     = ChannelType(0x00000004)
const AlphaChannel      = ChannelType(0x00000008)
const MatteChannel      = ChannelType(0x00000008)
const OpacityChannel    = ChannelType(0x00000008)
const BlackChannel      = ChannelType(0x00000020)
const IndexChannel      = ChannelType(0x00000020)
const CompositeChannels = ChannelType(0x0000002F)
const TrueAlphaChannel  = ChannelType(0x00000040)
const RGBChannels       = ChannelType(0x00000080)
const GrayChannels      = ChannelType(0x00000080)
const SyncChannels      = ChannelType(0x00000100)
const AllChannels       = ChannelType(0x7fffffff)
const DefaultChannels   = ChannelType((AllChannels.value | SyncChannels.value) & ~OpacityChannel.value)


# Image type
const IMType = ["BilevelType", "GrayscaleType", "GrayscaleMatteType", "PaletteType", "PaletteMatteType", "TrueColorType", "TrueColorMatteType", "ColorSeparationType", "ColorSeparationMatteType", "OptimizeType", "PaletteBilevelMatteType"]
const IMTypedict = Dict([(IMType[i], i) for i = 1:length(IMType)])

const CStoIMTypedict = Dict("Gray" => "GrayscaleType", "GrayA" => "GrayscaleMatteType", "AGray" => "GrayscaleMatteType", "RGB" => "TrueColorType", "ARGB" => "TrueColorMatteType", "RGBA" => "TrueColorMatteType", "CMYK" => "ColorSeparationType", "I"=>"GrayscaleType", "IA"=>"GrayscaleMatteType", "AI"=>"GrayscaleMatteType", "BGRA"=>"TrueColorMatteType", "ABGR"=>"TrueColorMatteType")

# Colorspace
const IMColorspace = ["RGB", "Gray", "Transparent", "OHTA", "Lab", "XYZ", "YCbCr", "YCC", "YIQ", "YPbPr", "YUV", "CMYK", "sRGB"]
const IMColordict = Dict([(IMColorspace[i], i) for i = 1:length(IMColorspace)])
for AC in vcat(subtypes(AlphaColor), subtypes(ColorAlpha))
    Cstr = ColorTypes.colorant_string(color_type(AC))
    if haskey(IMColordict, Cstr)
        IMColordict[ColorTypes.colorant_string(AC)] = IMColordict[Cstr]
    end
end

flip1(A)  = flipdim(A, 1)
flip2(A)  = flipdim(A, 2)
function flip12(A)
    inds = Any[indices(A)...]
    inds[1] = reverse(inds[1])
    inds[2] = reverse(inds[2])
    A[inds...]
end
pd(A) = permutedims(A, [2;1;3:ndims(A)])

const orientation_dict = Dict(nothing => pd,
    "1" => pd,
    "2" => A->pd(flip1(A)),
    "3" => A->pd(flip12(A)),
    "4" => A->pd(flip2(A)),
    "5" => identity,
    "6" => flip2,
    "7" => flip12,
    "8" => flip1)

function nchannels(imtype::AbstractString, cs::AbstractString, havealpha = false)
    n = 3
    if startswith(imtype, "Grayscale") || startswith(imtype, "Bilevel")
        n = 1
        cs = havealpha ? "GrayA" : "Gray"
    elseif cs == "CMYK"
        n = 4
    else
        cs = havealpha ? "ARGB" : "RGB" # only remaining variants supported by exportimagepixels
    end
    n + havealpha, cs
end

# channelorder = ["Gray" => "I", "GrayA" => "IA", "RGB" => "RGB", "ARGB" => "ARGB", "RGBA" => "RGBA", "CMYK" => "CMYK"]

# Compression
const NoCompression = 1

type MagickWand
    ptr::Ptr{Void}

    function MagickWand()
        ptr = ccall(NewMagickWand[], Ptr{Void}, ())
        ptr == C_NULL && throw(OutOfMemoryError())
        obj = new(ptr)
        finalizer(obj, free)
        obj
    end
end

function Base.unsafe_convert(::Type{Ptr{Void}}, wand::MagickWand)
    ptr = wand.ptr
    ptr == C_NULL && throw(UndefRefError())
    ptr
end

function free(wand::MagickWand)
    ptr = wand.ptr
    if ptr != C_NULL
        ccall(DestroyMagickWand[], Ptr{Void}, (Ptr{Void},), ptr)
    end
    wand.ptr = C_NULL
    nothing
end

type PixelWand
    ptr::Ptr{Void}

    function PixelWand()
        ptr = ccall(NewPixelWand[], Ptr{Void}, ())
        ptr == C_NULL && throw(OutOfMemoryError())
        obj = new(ptr)
        finalizer(obj, free)
        obj
    end
end

function Base.unsafe_convert(::Type{Ptr{Void}}, wand::PixelWand)
    ptr = wand.ptr
    ptr == C_NULL && throw(UndefRefError())
    ptr
end

function free(wand::PixelWand)
    ptr = wand.ptr
    if ptr != C_NULL
        ccall(DestroyPixelWand[], Ptr{Void}, (Ptr{Void},), ptr)
    end
    wand.ptr = C_NULL
    nothing
end

const IMExceptionType = Ref{Cint}()
function error(wand::MagickWand)
    pMsg = ccall(MagickGetException[], Ptr{UInt8}, (Ptr{Void}, Ptr{Cint}), wand, IMExceptionType)
    msg = unsafe_string(pMsg)
    relinquishmemory(pMsg)
    error(msg)
end
function error(wand::PixelWand)
    pMsg = ccall(PixelGetException[], Ptr{UInt8}, (Ptr{Void}, Ptr{Cint}), wand, IMExceptionType)
    msg = unsafe_string(pMsg)
    relinquishmemory(pMsg)
    error(msg)
end

function getsize(buffer, channelorder)
    if channelorder == "I"
        return size(buffer, 1), size(buffer, 2), size(buffer, 3)
    else
        return size(buffer, 2), size(buffer, 3), size(buffer, 4)
    end
end
getsize{C<:Colorant}(buffer::AbstractArray{C}, channelorder) = size(buffer, 1), size(buffer, 2), size(buffer, 3)

colorsize(buffer, channelorder) = channelorder == "I" ? 1 : size(buffer, 1)
colorsize{C<:Colorant}(buffer::AbstractArray{C}, channelorder) = 1

bitdepth{C<:Colorant}(buffer::AbstractArray{C}) = 8*sizeof(eltype(C))
bitdepth{T}(buffer::AbstractArray{T}) = 8*sizeof(T)

# colorspace is included for consistency with constituteimage, but it is not used
function exportimagepixels!{T<:Unsigned}(buffer::AbstractArray{T}, wand::MagickWand,  colorspace::String, channelorder::String; x = 0, y = 0)
    cols, rows, nimages = getsize(buffer, channelorder)
    ncolors = colorsize(buffer, channelorder)
    p = pointer(buffer)
    for i = 1:nimages
        nextimage(wand)
        status = ccall(MagickExportImagePixels[], Cint, (Ptr{Void}, Cssize_t, Cssize_t, Csize_t, Csize_t, Ptr{UInt8}, Cint, Ptr{Void}), wand, x, y, cols, rows, channelorder, storagetype(T), p)
        status == 0 && error(wand)
        p += sizeof(T)*cols*rows*ncolors
    end
    buffer
end

# function importimagepixels{T}(buffer::AbstractArray{T}, wand::MagickWand, colorspace::String; x = 0, y = 0)
#     cols, rows = getsize(buffer, colorspace)
#     status = ccall(MagickImportImagePixels[], Cint, (Ptr{Void}, Cssize_t, Cssize_t, Csize_t, Csize_t, Ptr{UInt8}, Cint, Ptr{Void}), wand, x, y, cols, rows, channelorder[colorspace], storagetype(T), buffer)
#     status == 0 && error(wand)
#     nothing
# end

function constituteimage{T<:Unsigned}(buffer::AbstractArray{T}, wand::MagickWand, colorspace::String, channelorder::String; x = 0, y = 0)
    cols, rows, nimages = getsize(buffer, channelorder)
    ncolors = colorsize(buffer, channelorder)
    p = pointer(buffer)
    depth = bitdepth(buffer)
    for i = 1:nimages
        status = ccall(MagickConstituteImage[], Cint, (Ptr{Void}, Cssize_t, Cssize_t, Ptr{UInt8}, Cint, Ptr{Void}), wand, cols, rows, channelorder, storagetype(T), p)
        status == 0 && error(wand)
        setimagecolorspace(wand, colorspace)
        setimagetype(wand, buffer, channelorder)
        status = ccall(MagickSetImageDepth[], Cint, (Ptr{Void}, Csize_t), wand, depth)
        status == 0 && error(wand)
        p += sizeof(T)*cols*rows*ncolors
    end
    nothing
end

function getblob(wand::MagickWand, format::AbstractString)
    setimageformat(wand, format)
    len = Ref{Csize_t}(1)
    ptr = ccall(MagickGetImagesBlob[], Ptr{UInt8}, (Ptr{Void}, Ptr{Csize_t}), wand, len)
    blob = unsafe_wrap(Array, ptr, convert(Int, len[]))
    finalizer(blob, relinquishmemory)
    blob
end

function pingimage(wand::MagickWand, filename::AbstractString)
    status = ccall(MagickPingImage[], Cint, (Ptr{Void}, Ptr{UInt8}), wand, filename)
    status == 0 && error(wand)
    nothing
end

function readimage(wand::MagickWand, filename::AbstractString)
    status = ccall(MagickReadImage[], Cint, (Ptr{Void}, Ptr{UInt8}), wand, filename)
    status == 0 && error(wand)
    nothing
end

function readimage(wand::MagickWand, stream::IO)
    status = ccall(MagickReadImageFile[], Cint, (Ptr{Void}, Ptr{Void}), wand, Libc.FILE(stream).ptr)
    status == 0 && error(wand)
    nothing
end

function readimage(wand::MagickWand, stream::Vector{UInt8})
    status = ccall(MagickReadImageBlob[], Cint, (Ptr{Void}, Ptr{Void}, Cint), wand, stream, length(stream)*sizeof(eltype(stream)))
    status == 0 && error(wand)
    nothing
end

function writeimage(wand::MagickWand, filename::AbstractString)
    status = ccall(MagickWriteImages[], Cint, (Ptr{Void}, Ptr{UInt8}, Cint), wand, filename, true)
    status == 0 && error(wand)
    nothing
end

function writeimage(wand::MagickWand, stream::IO)
    status = ccall(MagickWriteImagesFile[], Cint, (Ptr{Void}, Ptr{Void}), wand, Libc.FILE(stream).ptr)
    status == 0 && error(wand)
    nothing
end

function size(wand::MagickWand)
    height = ccall(MagickGetImageHeight[], Csize_t, (Ptr{Void},), wand)
    width = ccall(MagickGetImageWidth[], Csize_t, (Ptr{Void},), wand)
    return convert(Int, width), convert(Int, height)
end

getnumberimages(wand::MagickWand) = convert(Int, ccall(MagickGetNumberImages[], Csize_t, (Ptr{Void},), wand))

nextimage(wand::MagickWand) = ccall(MagickNextImage[], Cint, (Ptr{Void},), wand) == 1

resetiterator(wand::MagickWand) = ccall(MagickResetIterator[], Void, (Ptr{Void},), wand)

newimage(wand::MagickWand, cols::Integer, rows::Integer, pw::PixelWand) = ccall(MagickNewImage[], Cint, (Ptr{Void}, Csize_t, Csize_t, Ptr{Void}), wand, cols, rows, pw.ptr) == 0 && error(wand)

# test whether image has an alpha channel
getimagealphachannel(wand::MagickWand) = ccall(MagickGetImageAlphaChannel[], Cint, (Ptr{Void},), wand) == 1


function getimageproperties(wand::MagickWand,patt::AbstractString)
    numbProp = Ref{Csize_t}(0)
    p = ccall(MagickGetImageProperties[], Ptr{Ptr{UInt8}}, (Ptr{Void}, Ptr{UInt8}, Ptr{Csize_t}), wand, patt, numbProp)
    if p == C_NULL
        error("Pattern not in property names")
    else
        nP = convert(Int, numbProp[])
        ret = Vector{String}(nP)
        for i = 1:nP
            ret[i] = unsafe_string(unsafe_load(p,i))
        end
        ret
    end
end

function getimageproperty(wand::MagickWand, prop::AbstractString, warnuser::Bool=true)
    p = ccall(MagickGetImageProperty[], Ptr{UInt8}, (Ptr{Void}, Ptr{UInt8}), wand, prop)
    if p == convert(Ptr{UInt8}, C_NULL)
        if warnuser
            possib = getimageproperties(wand,"*")
            warn("Undefined property, possible names are \"$(join(possib,"\",\""))\"")
        end
        nothing
    else
        unsafe_string(p)
    end
end

# # get number of colors in the image
# magickgetimagecolors(wand::MagickWand) = ccall(MagickGetImageColors[], Csize_t, (Ptr{Void},), wand)

# get the type
function getimagetype(wand::MagickWand)
    t = ccall(MagickGetImageType[], Cint, (Ptr{Void},), wand)
    # Apparently the following is necessary, because the type is "potential"
    ccall(MagickSetImageType[], Void, (Ptr{Void}, Cint), wand, t)
    1 <= t <= length(IMType) || error("Image type ", t, " not recognized")
    IMType[t]
end

# get the colorspace
function getimagecolorspace(wand::MagickWand)
    cs = ccall(MagickGetImageColorspace[], Cint, (Ptr{Void},), wand)
    1 <= cs <= length(IMColorspace) || error("Colorspace ", cs, " not recognized")
    IMColorspace[cs]
end

function setimagecolorspace(wand::MagickWand, cs::String)
    status = ccall(MagickSetImageColorspace[], Cint, (Ptr{Void}, Cint), wand, IMColordict[cs])
    status == 0 && error(wand)
    nothing
end

imtype(buffer, cs) = IMTypedict[CStoIMTypedict[cs]]
imtype(buffer::AbstractArray{Bool}, cs) = IMTypedict["BilevelType"]

function setimagetype(wand::MagickWand, buffer, cs::String)
    status = ccall(MagickSetImageType[], Cint, (Ptr{Void}, Cint), wand, imtype(buffer, cs))
    status == 0 && error(wand)
    nothing
end

# set the compression
function setimagecompression(wand::MagickWand, compression::Integer)
    status = ccall(MagickSetImageCompression[], Cint, (Ptr{Void}, Cint), wand, Int32(compression))
    status == 0 && error(wand)
    nothing
end

function setimagecompressionquality(wand::MagickWand, quality::Integer)
    0 < quality <= 100 || error("quality setting must be in the (inclusive) range 1-100.\nSee http://www.imagemagick.org/script/command-line-options.php#quality for details")
    status = ccall(MagickSetImageCompressionQuality[], Cint, (Ptr{Void}, Cint), wand, quality)
    status == 0 && error(wand)
    nothing
end

# set fps (for GIF-type images)
function getimagetickspersecond(wand::MagickWand)
    ccall(MagickGetImageTicksPerSecond[], Cint, (Ptr{Void},), wand)
end

function getimagedelay(wand::MagickWand)
    ccall(MagickGetImageDelay[], Cint, (Ptr{Void},), wand)
end

function setimagedelay(wand::MagickWand, fps)
    tps = getimagetickspersecond(wand)
    delay = round(Int, tps/fps)
    for i = 1:getnumberimages(wand)+1  # not clear why +1
        status = ccall(MagickSetImageDelay[], Cint, (Ptr{Void}, Csize_t), wand, delay)
        status == 0 && error(wand)
        nextimage(wand)
    end
    resetiterator(wand)
    nothing
end

# set the image format
function setimageformat(wand::MagickWand, format::String)
    status = ccall(MagickSetImageFormat[], Cint, (Ptr{Void}, Ptr{UInt8}), wand, format)
    status == 0 && error(wand)
    nothing
end

# get the pixel depth
getimagedepth(wand::MagickWand) = convert(Int, ccall(MagickGetImageDepth[], Csize_t, (Ptr{Void},), wand))

# pixel depth for given channel type
getimagechanneldepth(wand::MagickWand, channelType::ChannelType) = convert(Int, ccall(MagickGetImageChannelDepth[], Csize_t, (Ptr{Void}, UInt32), wand, channelType.value))

pixelsetcolor(wand::PixelWand, colorstr::String) = ccall(PixelSetColor[], Csize_t, (Ptr{Void}, Ptr{UInt8}), wand, colorstr) == 0 && error(wand)

relinquishmemory(p) = ccall(MagickRelinquishMemory[], Ptr{UInt8}, (Ptr{UInt8},), p)

# get library information
# If you pass in "*", you get the full list of options
function queryoptions(pattern::AbstractString)
    nops = Ref{Cint}()
    pops = ccall(MagickQueryConfigureOptions[], Ptr{Ptr{UInt8}}, (Ptr{UInt8}, Ptr{Cint}), pattern, nops)
    ret = Vector{String}(nops[])
    for i = 1:nops[]
        ret[i] = unsafe_string(unsafe_load(pops, i))
    end
    ret
end

# queries the value of a particular option
function queryoption(option::AbstractString)
    p = ccall(MagickQueryConfigureOption[], Ptr{UInt8}, (Ptr{UInt8},), option)
    unsafe_string(p)
end
