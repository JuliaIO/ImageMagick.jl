NewMagickWand() = ccall((:NewMagickWand, libwand), Ptr{Void}, ())
DestroyMagickWand(wand::MagickWand) = ccall((:DestroyMagickWand, libwand), Ptr{Void}, (Ptr{Void},), wand.ptr)
NewPixelWand() = ccall((:NewPixelWand, libwand), Ptr{Void}, ())
DestroyPixelWand(wand::PixelWand) = ccall((:DestroyPixelWand, libwand), Ptr{Void}, (Ptr{Void},), wand.ptr)
MagickGetException(wand::MagickWand, im_exception_type::Vector{Cint}) = ccall((:MagickGetException, libwand), Ptr{Uint8}, (Ptr{Void}, Ptr{Cint}), wand.ptr, im_exception_type)
PixelGetException(wand::PixelWand, im_exception_type::Vector{Cint}) = ccall((:PixelGetException, libwand), Ptr{Uint8}, (Ptr{Void}, Ptr{Cint}), wand.ptr, im_exception_type)

MagickExportImagePixels(wand::MagickWand, x, y, cols, rows, channelorder, storaget, p) = ccall((:MagickExportImagePixels, libwand), Cint, (Ptr{Void}, Cssize_t, Cssize_t, Csize_t, Csize_t, Ptr{Uint8}, Cint, Ptr{Void}), wand.ptr, x, y, cols, rows, channelorder, storaget, p)
MagickConstituteImage(wand::MagickWand, cols, rows, channelorder, storaget, p) = ccall((:MagickConstituteImage, libwand), Cint, (Ptr{Void}, Cssize_t, Cssize_t, Ptr{Uint8}, Cint, Ptr{Void}), wand.ptr, cols, rows, channelorder, storaget, p)



MagickGetNumberImages(wand::MagickWand) = int(ccall((:MagickGetNumberImages, libwand), Csize_t, (Ptr{Void},), wand.ptr))

MagickNextImage(wand::MagickWand) = ccall((:MagickNextImage, libwand), Cint, (Ptr{Void},), wand.ptr)

MagickResetIterator(wand::MagickWand) = ccall((:MagickResetIterator, libwand), Void, (Ptr{Void},), wand.ptr)

MagickNewImage(wand::MagickWand, cols::Integer, rows::Integer, pw::PixelWand) = ccall((:MagickNewImage, libwand), Cint, (Ptr{Void}, Csize_t, Csize_t, Ptr{Void}), wand.ptr, cols, rows, pw.ptr)

# test whether image has an alpha channel
MagickGetImageAlphaChannel(wand::MagickWand) = ccall((:MagickGetImageAlphaChannel, libwand), Cint, (Ptr{Void},), wand.ptr)


ccall((:MagickSetImageDepth, libwand), Cint, (Ptr{Void}, Csize_t), wand.ptr, depth)
ccall((:MagickGetImagesBlob, libwand), Ptr{Uint8}, (Ptr{Void}, Ptr{Csize_t}), wand.ptr, len)
ccall((:MagickPingImage, libwand), Cint, (Ptr{Void}, Ptr{Uint8}), wand.ptr, filename)
ccall((:MagickReadImage, libwand), Cint, (Ptr{Void}, Ptr{Uint8}), wand.ptr, filename)
ccall((:MagickReadImageFile, libwand), Cint, (Ptr{Void}, Ptr{Void}), wand.ptr, CFILE(stream))
ccall((:MagickWriteImages, libwand), Cint, (Ptr{Void}, Ptr{Uint8}, Cint), wand.ptr, filename, true)
ccall((:MagickGetImageHeight, libwand), Csize_t, (Ptr{Void},), wand.ptr)
ccall((:MagickGetImageWidth, libwand), Csize_t, (Ptr{Void},), wand.ptr)
ccall((:MagickGetImageProperties, libwand),Ptr{Ptr{Uint8}},(Ptr{Void},Ptr{Uint8},Ptr{Csize_t}),wand.ptr,patt,numbProp)
ccall((:MagickGetImageProperty, libwand),Ptr{Uint8},(Ptr{Void},Ptr{Uint8}),wand.ptr,prop)
ccall((:MagickGetImageType, libwand), Cint, (Ptr{Void},), wand.ptr)
ccall((:MagickSetImageType, libwand), Void, (Ptr{Void}, Cint), wand.ptr, t)
ccall((:MagickGetImageColorspace, libwand), Cint, (Ptr{Void},), wand.ptr)
ccall((:MagickSetImageColorspace, libwand), Cint, (Ptr{Void},Cint), wand.ptr, IMColordict[cs])
ccall((:MagickSetImageCompression, libwand), Cint, (Ptr{Void},Cint), wand.ptr, int32(compression))
ccall((:MagickSetImageCompressionQuality, libwand), Cint, (Ptr{Void}, Cint), wand.ptr, quality)
ccall((:MagickSetImageFormat, libwand), Cint, (Ptr{Void}, Ptr{Uint8}), wand.ptr, format)
ccall((:MagickGetImageDepth, libwand), Csize_t, (Ptr{Void},), wand.ptr)
ccall((:MagickRelinquishMemory, libwand), Ptr{Uint8}, (Ptr{Uint8},), p)
ccall((:MagickQueryConfigureOptions, libwand), Ptr{Ptr{Uint8}}, (Ptr{Uint8}, Ptr{Cint}), pattern, nops)
ccall((:MagickQueryConfigureOption, libwand), Ptr{Uint8}, (Ptr{Uint8},), option)
  