let SUPPORTED_READ_FORMATS = Union(
File{:bmp}, #=Microsoft Windows bitmap By default the BMP format is version 4. Use BMP3 and BMP2 to write versions 3 and 2 respectively.=#
File{:bmp2}, #=Microsoft Windows bitmap By default the BMP format is version 4. Use BMP3 and BMP2 to write versions 3 and 2 respectively.=#
File{:bmp3}, #=Microsoft Windows bitmap By default the BMP format is version 4. Use BMP3 and BMP2 to write versions 3 and 2 respectively.=#
File{:aai}, #=AAI Dune image=#
File{:art}, #=PFS: 1st Publisher Format originally used on the Macintosh (MacPaint?) and later used for PFS: 1st Publisher clip art.=#
File{:arw}, #=Sony Digital Camera Alpha Raw Image Format=#
File{:avi}, #=Microsoft Audio/Visual Interleaved=#
File{:avs}, #=AVS X image=#
File{:cals}, #=Continuous Acquisition and Life-cycle Support Type 1 image Specified in MIL-R-28002 and MIL-PRF-28002. Standard blueprint archive format as used by the US military to replace microfiche.=#
File{:cgm}, #=Computer Graphics Metafile Requires ralcgm to render CGM files.=#
File{:cin}, #=Kodak Cineon Image Format Use -set to specify the image gamma or black and white points (e.g. -set gamma 1.7, -set reference-black 95, -set reference-white 685). Properties include cin:file.create_date, cin:file.create_time, cin:file.filename, cin:file.version, cin:film.count, cin:film.format, cin:film.frame_id, cin:film.frame_position, cin:film.frame_rate, cin:film.id, cin:film.offset, cin:film.prefix, cin:film.slate_info, cin:film.type, cin:image.label, cin:origination.create_date, cin:origination.create_time, cin:origination.device, cin:origination.filename, cin:origination.model, cin:origination.serial, cin:origination.x_offset, cin:origination.x_pitch, cin:origination.y_offset, cin:origination.y_pitch, cin:user.data.=#
File{:cmyk}, #=Raw cyan, magenta, yellow, and black samples Use -size and -depth to specify the image width, height, and depth. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.=#
File{:cmyka}, #=Raw cyan, magenta, yellow, black, and alpha samples Use -size and -depth to specify the image width, height, and depth. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.=#
File{:cr2}, #=Canon Digital Camera Raw Image Format Requires an explicit image format otherwise the image is interpreted as a TIFF image (e.g. cr2:image.cr2).=#
File{:crw}, #=Canon Digital Camera Raw Image Format=#
File{:cur}, #=Microsoft Cursor Icon=#
File{:cut}, #=DR Halo=#
File{:dcm}, #=Digital Imaging and Communications in Medicine (DICOM) image Used by the medical community for images like X-rays. ImageMagick sets the initial display range based on the Window Center (0028,1050) and Window Width (0028,1051) tags. Use -define dcm:display-range=reset to set the display range to the minimum and maximum pixel values.=#
File{:dcr}, #=Kodak Digital Camera Raw Image File=#
File{:dcx}, #=ZSoft IBM PC multi-page Paintbrush image=#
File{:dds}, #=Microsoft Direct Draw Surface Use -define to specify the compression (e.g. -define dds:compression={dxt1, dxt5, none}). Other defines include dds:cluster-fit={true,false}, dds:weight-by-alpha={true,false}, and use dds:mipmaps to set the number of mipmaps.=#
File{:dib}, #=Microsoft Windows Device Independent Bitmap DIB is a BMP file without the BMP header. Used to support embedded images in compound formats like WMF.=#
File{:djvu}, #==#
File{:dng}, #=Digital Negative Requires an explicit image format otherwise the image is interpreted as a TIFF image (e.g. dng:image.dng).=#
File{:dot}, #=Graph Visualization Use -define to specify the layout engine (e.g. -define dot:layout-engine=twopi).=#
File{:dpx}, #=SMPTE Digital Moving Picture Exchange 2.0 (SMPTE 268M-2003) Use -set to specify the image gamma or black and white points (e.g. -set gamma 1.7, -set reference-black 95, -set reference-white 685).=#
File{:emf}, #=Microsoft Enhanced Metafile (32-bit) Only available under Microsoft Windows.=#
File{:epdf}, #=Encapsulated Portable Document Format=#
File{:epi}, #=Adobe Encapsulated PostScript Interchange format Requires Ghostscript to read.=#
File{:eps}, #=Adobe Encapsulated PostScript Requires Ghostscript to read.=#
File{:eps2}, #=Adobe Level II Encapsulated PostScript Requires Ghostscript to read.=#
File{:eps3}, #=Adobe Level III Encapsulated PostScript Requires Ghostscript to read.=#
File{:epsf}, #=Adobe Encapsulated PostScript Requires Ghostscript to read.=#
File{:epsi}, #=Adobe Encapsulated PostScript Interchange format Requires Ghostscript to read.=#
File{:ept}, #=Adobe Encapsulated PostScript Interchange format with TIFF preview Requires Ghostscript to read.=#
File{:exr}, #=High dynamic-range (HDR) file format developed by Industrial Light & Magic See High Dynamic-Range Images for details on this image format. Requires the OpenEXR delegate library.=#
File{:fax}, #=Group 3 TIFF This format is a fixed width of 1728 as required by the standard. See TIFF format. Note that FAX machines use non-square pixels which are 1.5 times wider than they are tall but computer displays use square pixels so FAX images may appear to be narrow unless they are explicitly resized using a resize specification of 100x150%.=#
File{:fig}, #=FIG graphics format Requires TransFig.=#
File{:fits}, #=Flexible Image Transport System To specify a single-precision floating-point format, use -define quantum:format=floating-point. Set the depth to 64 for a double-precision floating-point format.=#
File{:fpx}, #=FlashPix Format FlashPix has the option to store mega- and giga-pixel images at various resolutions in a single file which permits conservative bandwidth and fast reveal times when displayed within a Web browser. Requires the FlashPix SDK.=#
File{:gif}, #=CompuServe Graphics Interchange Format 8-bit RGB PseudoColor with up to 256 palette entires. Specify the format GIF87 to write the older version 87a of the format. Use -transparent-color to specify the GIF transparent color (e.g. -transparent-color wheat).=#
File{:gplt}, #=Gnuplot plot files Requires gnuplot4.0.tar.Z or later.=#
File{:gray}, #=Raw gray samples Use -size and -depth to specify the image width, height, and depth. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.=#
File{:hdr}, #=Radiance RGBE image format=#
File{:hpgl}, #=HP-GL plotter language Requires hp2xx-3.4.4.tar.gz=#
File{:hrz}, #=Slow Scane TeleVision=#
File{:html}, #=Hypertext Markup Language with a client-side image map Also known as HTM. Requires html2ps to read.=#
File{:ico}, #=Microsoft icon Also known as ICON.=#
File{:info}, #=Format and characteristics of the image=#
File{:inline}, #=Base64-encoded inline image The inline image look similar to inline:data:;base64,/9j/4AAQSk...knrn//2Q==. If the inline image exceeds 5000 characters, reference it from a file (e.g. inline:inline.txt). You can also write a base64-encoded image. Embed the mime type in the filename, for example, convert myimage inline:jpeg:myimage.txt.=#
File{:jbig}, #=Joint Bi-level Image experts Group file interchange format Also known as BIE and JBG. Requires jbigkit-1.6.tar.gz.=#
File{:jng}, #=Multiple-image Network Graphics JPEG in a PNG-style wrapper with transparency. Requires libjpeg and libpng-1.0.11 or later, libpng-1.2.5 or later recommended.=#
File{:jp2}, #=JPEG-2000 JP2 File Format Syntax Specify the encoding options with the -define option See JP2 Encoding Options for more details.=#
File{:jpt}, #=JPEG-2000 Code Stream Syntax Specify the encoding options with the -define option See JP2 Encoding Options for more details.=#
File{:j2c}, #=JPEG-2000 Code Stream Syntax Specify the encoding options with the -define option See JP2 Encoding Options for more details.=#
File{:j2k}, #=JPEG-2000 Code Stream Syntax Specify the encoding options with the -define option See JP2 Encoding Options for more details.=#
File{:jpeg}, #=Joint Photographic Experts Group JFIF format Note, JPEG is a lossy compression. In addition, you cannot create black and white images with JPEG nor can you save transparency.=#
File{:jpg}, #=Joint Photographic Experts Group JFIF format Note, JPEG is a lossy compression. In addition, you cannot create black and white images with JPEG nor can you save transparency.=#
File{:jxr}, #=JPEG extended range Requires the jxrlib delegate library. Put the JxrDecApp and JxrEncApp applications in your execution path.=#
File{:json}, #=JavaScript Object Notation, a lightweight data-interchange format Include additional attributes about the image with these defines: -define json:locate, -define json:limit, -define json:moments, or -define json:features.=#
File{:man}, #=Unix reference manual pages Requires that GNU groff and Ghostcript are installed.=#
File{:mat}, #=MATLAB image format=#
File{:miff}, #=Magick image file format This format persists all image attributes known to ImageMagick. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.=#
File{:mono}, #=Bi-level bitmap in least-significant-byte first order=#
File{:mng}, #=Multiple-image Network Graphics A PNG-like Image Format Supporting Multiple Images, Animation and Transparent JPEG. Requires libpng-1.0.11 or later, libpng-1.2.5 or later recommended. An interframe delay of 0 generates one frame with each additional layer composited on top. For motion, be sure to specify a non-zero delay.=#
File{:m2v}, #=Motion Picture Experts Group file interchange format (version 2) Requires ffmpeg.=#
File{:mpeg}, #=Motion Picture Experts Group file interchange format (version 1) Requires ffmpeg.=#
File{:mpc}, #=Magick Persistent Cache image file format The most efficient data processing pattern is a write-once, read-many-times pattern. The image is generated or copied from source, then various analyses are performed on the image pixels over time. MPC supports this pattern. MPC is the native in-memory ImageMagick uncompressed file format. This file format is identical to that used by ImageMagick to represent images in memory and is read by mapping the file directly into memory. The MPC format is not portable and is not suitable as an archive format. It is suitable as an intermediate format for high-performance image processing. The MPC format requires two files to support one image. Image attributes are written to a file with the extension .mpc, whereas, image pixels are written to a file with the extension .cache.=#
File{:mpr}, #=Magick Persistent Registry This format permits you to write to and read images from memory. The image persists until the program exits. For example, let's use the MPR to create a checkerboard:=#
File{:mrw}, #=Sony (Minolta) Raw Image File=#
File{:msl}, #=Magick Scripting Language MSL is the XML-based scripting language supported by the conjure utility. MSL requires the libxml2 delegate library.=#
File{:mtv}, #=MTV Raytracing image format=#
File{:mvg}, #=Magick Vector Graphics. The native ImageMagick vector metafile format. A text file containing vector drawing commands accepted by convert's -draw option.=#
File{:nef}, #=Nikon Digital SLR Camera Raw Image File=#
File{:orf}, #=Olympus Digital Camera Raw Image File=#
File{:otb}, #=On-the-air Bitmap=#
File{:p7}, #=Xv's Visual Schnauzer thumbnail format=#
File{:palm}, #=Palm pixmap=#
File{:pam}, #=Common 2-dimensional bitmap format=#
File{:pbm}, #=Portable bitmap format (black and white)=#
File{:pcd}, #=Photo CD The maximum resolution written is 768x512 pixels since larger images require huffman compression (which is not supported).=#
File{:pcds}, #=Photo CD Decode with the sRGB color tables.=#
File{:pcl}, #=HP Page Control Language Use -define to specify fit to page option (e.g. -define pcl:fit-to-page=true).=#
File{:pcx}, #=ZSoft IBM PC Paintbrush file=#
File{:pdb}, #=Palm Database ImageViewer Format=#
File{:pdf}, #=Portable Document Format Requires Ghostscript to read. By default, ImageMagick sets the page size to the MediaBox. Some PDF files, however, have a CropBox or TrimBox that is smaller than the MediaBox and may include white space, registration or cutting marks outside the CropBox or TrimBox. To force ImageMagick to use the CropBox or TrimBox rather than the MediaBox, use -define (e.g. -define pdf:use-cropbox=true or -define pdf:use-trimbox=true). Use -density to improve the appearance of your PDF rendering (e.g. -density 300x300). Use -alpha remove to remove transparency. To specify direct conversion from Postscript to PDF, use -define delegate:bimodel=true. Use -define pdf:fit-page=true to scale to the page size.=#
File{:pef}, #=Pentax Electronic File Requires an explicit image format otherwise the image is interpreted as a TIFF image (e.g. pef:image.pef).=#
File{:pfa}, #=Postscript Type 1 font (ASCII) Opening as file returns a preview image.=#
File{:pfb}, #=Postscript Type 1 font (binary) Opening as file returns a preview image.=#
File{:pfm}, #=Portable float map format=#
File{:pgm}, #=Portable graymap format (gray scale)=#
File{:picon}, #=Personal Icon=#
File{:pict}, #=Apple Macintosh QuickDraw/PICT file=#
File{:pix}, #=Alias/Wavefront RLE image format=#
File{:png}, #=Portable Network Graphics Requires libpng-1.0.11 or later, libpng-1.2.5 or later recommended. The PNG specification does not support pixels-per-inch units, only pixels-per-centimeter. To avoid reading a particular associated image profile, use -define profile:skip=name (e.g. profile:skip=ICC).=#
File{:png8}, #=Portable Network Graphics 8-bit indexed with optional binary transparency=#
File{:png00}, #=Portable Network Graphics PNG inheriting subformat from original=#
File{:png24}, #=Portable Network Graphics opaque or binary transparent 24-bit RGB=#
File{:png32}, #=Portable Network Graphics opaque or transparent 32-bit RGBA=#
File{:png48}, #=Portable Network Graphics opaque or binary transparent 48-bit RGB=#
File{:png64}, #=Portable Network Graphics opaque or transparent 64-bit RGB=#
File{:pnm}, #=Portable anymap PNM is a family of formats supporting portable bitmaps (PBM) , graymaps (PGM), and pixmaps (PPM). There is no file format associated with pnm itself. If PNM is used as the output format specifier, then ImageMagick automagically selects the most appropriate format to represent the image. The default is to write the binary version of the formats. Use -compress none to write the ASCII version of the formats.=#
File{:ppm}, #=Portable pixmap format (color)=#
File{:ps}, #=Adobe PostScript file Requires Ghostscript to read. To force ImageMagick to respect the crop box, use -define (e.g. -define eps:use-cropbox=true). Use -density to improve the appearance of your Postscript rendering (e.g. -density 300x300). Use -alpha remove to remove transparency. To specify direct conversion from PDF to Postscript, use -define delegate:bimodel=true.=#
File{:ps2}, #=Adobe Level II PostScript file Requires Ghostscript to read.=#
File{:ps3}, #=Adobe Level III PostScript file Requires Ghostscript to read.=#
File{:psb}, #=Adobe Large Document Format=#
File{:psd}, #=Adobe Photoshop bitmap file=#
File{:ptif}, #=Pyramid encoded TIFF Multi-resolution TIFF containing successively smaller versions of the image down to the size of an icon.=#
File{:pwp}, #=Seattle File Works multi-image file=#
File{:rad}, #=Radiance image file Requires that ra_ppm from the Radiance software package be installed.=#
File{:raf}, #=Fuji CCD-RAW Graphic File=#
File{:rgb}, #=Raw red, green, and blue samples Use -size and -depth to specify the image width, height, and depth. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.=#
File{:rgba}, #=Raw red, green, blue, and alpha samples Use -size and -depth to specify the image width, height, and depth. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.=#
File{:rfg}, #=LEGO Mindstorms EV3 Robot Graphics File=#
File{:rla}, #=Alias/Wavefront image file=#
File{:rle}, #=Utah Run length encoded image file=#
File{:sct}, #=Scitex Continuous Tone Picture=#
File{:sfw}, #=Seattle File Works image=#
File{:sgi}, #=Irix RGB image=#
File{:shtml}, #=Hypertext Markup Language client-side image map Used to write HTML clickable image maps based on a the output of montage or a format which supports tiled images such as MIFF.=#
File{:sid,}, #=R Multiresolution seamless image Requires the mrsidgeodecode command line utility that decompresses MG2 or MG3 SID image files.=#
File{:sun}, #=SUN Rasterfile=#
File{:svg}, #=Scalable Vector Graphics ImageMagick utilizes inkscape if its in your execution path otherwise RSVG. If neither are available, ImageMagick reverts to its internal SVG renderer. The default resolution is 90dpi.=#
File{:tga}, #=Truevision Targa image Also known as formats ICB, VDA, and VST.=#
File{:tiff}, #=Tagged Image File Format Also known as TIF. Requires tiff-v3.6.1.tar.gz or later. Use -define to specify the rows per strip (e.g. -define tiff:rows-per-strip=8). To define the tile geometry, use for example, -define tiff:tile-geometry=128x128. To specify a signed format, use -define quantum:format=signed. To specify a single-precision floating-point format, use -define quantum:format=floating-point. Set the depth to 64 for a double-precision floating-point format. Use -define quantum:polarity=min-is-black or -define quantum:polarity=min-is-white toggle the photometric interpretation for a bilevel image. Specify the extra samples as associated or unassociated alpha with, for example, -define tiff:alpha=unassociated. Set the fill order with -define tiff:fill-order=msb|lsb. Set the TIFF endianess with -define tiff:endian=msb|lsb. Use -define tiff:exif-properties=false to skip reading the EXIF properties. You can set a number of TIFF software attributes including document name, host computer, artist, timestamp, make, model, software, and copyright. For example, -set tiff:software "My Company". If you want to ignore certain TIFF tags, use this option: -define tiff:ignore-tags=comma-separated-list-of-tag-IDs=#
File{:tim}, #=PSX TIM file=#
File{:ttf}, #=TrueType font file Requires freetype 2. Opening as file returns a preview image. Use -set if you do not want to hint glyph outlines after their scaling to device pixels (e.g. -set type:hinting off).=#
File{:txt}, #=Raw text file=#
File{:uil}, #=X-Motif UIL table=#
File{:uyvy}, #=Interleaved YUV raw image Use -size and -depth command line options to specify width and height. Use -sampling-factor to set the desired subsampling (e.g. -sampling-factor 4:2:2).=#
File{:vicar}, #=VICAR rasterfile format=#
File{:viff}, #=Khoros Visualization Image File Format=#
File{:wbmp}, #=Wireless bitmap Support for uncompressed monochrome only.=#
File{:wdp}, #=JPEG extended range Requires the jxrlib delegate library. Put the JxrDecApp and JxrEncApp applications in your execution path.=#
File{:webp}, #=Weppy image format Requires the WEBP delegate library. Specify the encoding options with the -define option See WebP Encoding Options for more details.=#
File{:wmf}, #=Windows Metafile Requires libwmf. By default, renders WMF files using the dimensions specified by the metafile header. Use the -density option to adjust the output resolution, and thereby adjust the output size. The default output resolution is 72DPI so -density 144 results in an image twice as large as the default. Use -background color to specify the WMF background color (default white) or -texture filename to specify a background texture image.=#
File{:wpg}, #=Word Perfect Graphics File=#
File{:x}, #=display or import an image to or from an X11 server Use -define to obtain the image from the root window (e.g. -define x:screen=true). Set x:silent=true to turn off the beep when importing an image.=#
File{:xbm}, #=X Windows system bitmap, black and white only Used by the X Windows System to store monochrome icons.=#
File{:xcf}, #=GIMP image=#
File{:xpm}, #=X Windows system pixmap Also known as PM. Used by the X Windows System to store color icons.=#
File{:xwd}, #=X Windows system window dump Used by the X Windows System to save/display screen dumps.=#
File{:x3f}, #=Sigma Camera RAW Picture File=#
File{:ycbcr}, #=Raw Y, Cb, and Cr samples Use -size and -depth to specify the image width, height, and depth.=#
File{:ycbcra}, #=Raw Y, Cb, Cr, and alpha samples Use -size and -depth to specify the image width, height, and depth.=#
File{:yuv} #==#
)
FileIO.readformats(::Type{Val{:imagemagick}}) = SUPPORTED_READ_FORMATS
end

let SUPPORTED_WRITE_FORMATS = Union(
File{:bmp}, #=Microsoft Windows bitmap By default the BMP format is version 4. Use BMP3 and BMP2 to write versions 3 and 2 respectively.=#
File{:bmp2}, #=Microsoft Windows bitmap By default the BMP format is version 4. Use BMP3 and BMP2 to write versions 3 and 2 respectively.=#
File{:bmp3}, #=Microsoft Windows bitmap By default the BMP format is version 4. Use BMP3 and BMP2 to write versions 3 and 2 respectively.=#
File{:aai}, #=AAI Dune image=#
File{:art}, #=PFS: 1st Publisher Format originally used on the Macintosh (MacPaint?) and later used for PFS: 1st Publisher clip art.=#
File{:arw}, #=Sony Digital Camera Alpha Raw Image Format=#
File{:avi}, #=Microsoft Audio/Visual Interleaved=#
File{:avs}, #=AVS X image=#
File{:cals}, #=Continuous Acquisition and Life-cycle Support Type 1 image Specified in MIL-R-28002 and MIL-PRF-28002. Standard blueprint archive format as used by the US military to replace microfiche.=#
File{:cgm}, #=Computer Graphics Metafile Requires ralcgm to render CGM files.=#
File{:cin}, #=Kodak Cineon Image Format Use -set to specify the image gamma or black and white points (e.g. -set gamma 1.7, -set reference-black 95, -set reference-white 685). Properties include cin:file.create_date, cin:file.create_time, cin:file.filename, cin:file.version, cin:film.count, cin:film.format, cin:film.frame_id, cin:film.frame_position, cin:film.frame_rate, cin:film.id, cin:film.offset, cin:film.prefix, cin:film.slate_info, cin:film.type, cin:image.label, cin:origination.create_date, cin:origination.create_time, cin:origination.device, cin:origination.filename, cin:origination.model, cin:origination.serial, cin:origination.x_offset, cin:origination.x_pitch, cin:origination.y_offset, cin:origination.y_pitch, cin:user.data.=#
File{:cmyk}, #=Raw cyan, magenta, yellow, and black samples Use -size and -depth to specify the image width, height, and depth. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.=#
File{:cmyka}, #=Raw cyan, magenta, yellow, black, and alpha samples Use -size and -depth to specify the image width, height, and depth. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.=#
File{:cr2}, #=Canon Digital Camera Raw Image Format Requires an explicit image format otherwise the image is interpreted as a TIFF image (e.g. cr2:image.cr2).=#
File{:crw}, #=Canon Digital Camera Raw Image Format=#
File{:cur}, #=Microsoft Cursor Icon=#
File{:cut}, #=DR Halo=#
File{:dcm}, #=Digital Imaging and Communications in Medicine (DICOM) image Used by the medical community for images like X-rays. ImageMagick sets the initial display range based on the Window Center (0028,1050) and Window Width (0028,1051) tags. Use -define dcm:display-range=reset to set the display range to the minimum and maximum pixel values.=#
File{:dcr}, #=Kodak Digital Camera Raw Image File=#
File{:dcx}, #=ZSoft IBM PC multi-page Paintbrush image=#
File{:dds}, #=Microsoft Direct Draw Surface Use -define to specify the compression (e.g. -define dds:compression={dxt1, dxt5, none}). Other defines include dds:cluster-fit={true,false}, dds:weight-by-alpha={true,false}, and use dds:mipmaps to set the number of mipmaps.=#
File{:dib}, #=Microsoft Windows Device Independent Bitmap DIB is a BMP file without the BMP header. Used to support embedded images in compound formats like WMF.=#
File{:djvu}, #==#
File{:dng}, #=Digital Negative Requires an explicit image format otherwise the image is interpreted as a TIFF image (e.g. dng:image.dng).=#
File{:dot}, #=Graph Visualization Use -define to specify the layout engine (e.g. -define dot:layout-engine=twopi).=#
File{:dpx}, #=SMPTE Digital Moving Picture Exchange 2.0 (SMPTE 268M-2003) Use -set to specify the image gamma or black and white points (e.g. -set gamma 1.7, -set reference-black 95, -set reference-white 685).=#
File{:emf}, #=Microsoft Enhanced Metafile (32-bit) Only available under Microsoft Windows.=#
File{:epdf}, #=Encapsulated Portable Document Format=#
File{:epi}, #=Adobe Encapsulated PostScript Interchange format Requires Ghostscript to read.=#
File{:eps}, #=Adobe Encapsulated PostScript Requires Ghostscript to read.=#
File{:eps2}, #=Adobe Level II Encapsulated PostScript Requires Ghostscript to read.=#
File{:eps3}, #=Adobe Level III Encapsulated PostScript Requires Ghostscript to read.=#
File{:epsf}, #=Adobe Encapsulated PostScript Requires Ghostscript to read.=#
File{:epsi}, #=Adobe Encapsulated PostScript Interchange format Requires Ghostscript to read.=#
File{:ept}, #=Adobe Encapsulated PostScript Interchange format with TIFF preview Requires Ghostscript to read.=#
File{:exr}, #=High dynamic-range (HDR) file format developed by Industrial Light & Magic See High Dynamic-Range Images for details on this image format. Requires the OpenEXR delegate library.=#
File{:fax}, #=Group 3 TIFF This format is a fixed width of 1728 as required by the standard. See TIFF format. Note that FAX machines use non-square pixels which are 1.5 times wider than they are tall but computer displays use square pixels so FAX images may appear to be narrow unless they are explicitly resized using a resize specification of 100x150%.=#
File{:fig}, #=FIG graphics format Requires TransFig.=#
File{:fits}, #=Flexible Image Transport System To specify a single-precision floating-point format, use -define quantum:format=floating-point. Set the depth to 64 for a double-precision floating-point format.=#
File{:fpx}, #=FlashPix Format FlashPix has the option to store mega- and giga-pixel images at various resolutions in a single file which permits conservative bandwidth and fast reveal times when displayed within a Web browser. Requires the FlashPix SDK.=#
File{:gif}, #=CompuServe Graphics Interchange Format 8-bit RGB PseudoColor with up to 256 palette entires. Specify the format GIF87 to write the older version 87a of the format. Use -transparent-color to specify the GIF transparent color (e.g. -transparent-color wheat).=#
File{:gplt}, #=Gnuplot plot files Requires gnuplot4.0.tar.Z or later.=#
File{:gray}, #=Raw gray samples Use -size and -depth to specify the image width, height, and depth. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.=#
File{:hdr}, #=Radiance RGBE image format=#
File{:hpgl}, #=HP-GL plotter language Requires hp2xx-3.4.4.tar.gz=#
File{:hrz}, #=Slow Scane TeleVision=#
File{:html}, #=Hypertext Markup Language with a client-side image map Also known as HTM. Requires html2ps to read.=#
File{:ico}, #=Microsoft icon Also known as ICON.=#
File{:info}, #=Format and characteristics of the image=#
File{:inline}, #=Base64-encoded inline image The inline image look similar to inline:data:;base64,/9j/4AAQSk...knrn//2Q==. If the inline image exceeds 5000 characters, reference it from a file (e.g. inline:inline.txt). You can also write a base64-encoded image. Embed the mime type in the filename, for example, convert myimage inline:jpeg:myimage.txt.=#
File{:jbig}, #=Joint Bi-level Image experts Group file interchange format Also known as BIE and JBG. Requires jbigkit-1.6.tar.gz.=#
File{:jng}, #=Multiple-image Network Graphics JPEG in a PNG-style wrapper with transparency. Requires libjpeg and libpng-1.0.11 or later, libpng-1.2.5 or later recommended.=#
File{:jp2}, #=JPEG-2000 JP2 File Format Syntax Specify the encoding options with the -define option See JP2 Encoding Options for more details.=#
File{:jpt}, #=JPEG-2000 Code Stream Syntax Specify the encoding options with the -define option See JP2 Encoding Options for more details.=#
File{:j2c}, #=JPEG-2000 Code Stream Syntax Specify the encoding options with the -define option See JP2 Encoding Options for more details.=#
File{:j2k}, #=JPEG-2000 Code Stream Syntax Specify the encoding options with the -define option See JP2 Encoding Options for more details.=#
File{:jpeg}, #=Joint Photographic Experts Group JFIF format Note, JPEG is a lossy compression. In addition, you cannot create black and white images with JPEG nor can you save transparency.=#
File{:jxr}, #=JPEG extended range Requires the jxrlib delegate library. Put the JxrDecApp and JxrEncApp applications in your execution path.=#
File{:json}, #=JavaScript Object Notation, a lightweight data-interchange format Include additional attributes about the image with these defines: -define json:locate, -define json:limit, -define json:moments, or -define json:features.=#
File{:man}, #=Unix reference manual pages Requires that GNU groff and Ghostcript are installed.=#
File{:mat}, #=MATLAB image format=#
File{:miff}, #=Magick image file format This format persists all image attributes known to ImageMagick. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.=#
File{:mono}, #=Bi-level bitmap in least-significant-byte first order=#
File{:mng}, #=Multiple-image Network Graphics A PNG-like Image Format Supporting Multiple Images, Animation and Transparent JPEG. Requires libpng-1.0.11 or later, libpng-1.2.5 or later recommended. An interframe delay of 0 generates one frame with each additional layer composited on top. For motion, be sure to specify a non-zero delay.=#
File{:m2v}, #=Motion Picture Experts Group file interchange format (version 2) Requires ffmpeg.=#
File{:mpeg}, #=Motion Picture Experts Group file interchange format (version 1) Requires ffmpeg.=#
File{:mpc}, #=Magick Persistent Cache image file format The most efficient data processing pattern is a write-once, read-many-times pattern. The image is generated or copied from source, then various analyses are performed on the image pixels over time. MPC supports this pattern. MPC is the native in-memory ImageMagick uncompressed file format. This file format is identical to that used by ImageMagick to represent images in memory and is read by mapping the file directly into memory. The MPC format is not portable and is not suitable as an archive format. It is suitable as an intermediate format for high-performance image processing. The MPC format requires two files to support one image. Image attributes are written to a file with the extension .mpc, whereas, image pixels are written to a file with the extension .cache.=#
File{:mpr}, #=Magick Persistent Registry This format permits you to write to and read images from memory. The image persists until the program exits. For example, let's use the MPR to create a checkerboard:=#
File{:mrw}, #=Sony (Minolta) Raw Image File=#
File{:msl}, #=Magick Scripting Language MSL is the XML-based scripting language supported by the conjure utility. MSL requires the libxml2 delegate library.=#
File{:mtv}, #=MTV Raytracing image format=#
File{:mvg}, #=Magick Vector Graphics. The native ImageMagick vector metafile format. A text file containing vector drawing commands accepted by convert's -draw option.=#
File{:nef}, #=Nikon Digital SLR Camera Raw Image File=#
File{:orf}, #=Olympus Digital Camera Raw Image File=#
File{:otb}, #=On-the-air Bitmap=#
File{:p7}, #=Xv's Visual Schnauzer thumbnail format=#
File{:palm}, #=Palm pixmap=#
File{:pam}, #=Common 2-dimensional bitmap format=#
File{:pbm}, #=Portable bitmap format (black and white)=#
File{:pcd}, #=Photo CD The maximum resolution written is 768x512 pixels since larger images require huffman compression (which is not supported).=#
File{:pcds}, #=Photo CD Decode with the sRGB color tables.=#
File{:pcl}, #=HP Page Control Language Use -define to specify fit to page option (e.g. -define pcl:fit-to-page=true).=#
File{:pcx}, #=ZSoft IBM PC Paintbrush file=#
File{:pdb}, #=Palm Database ImageViewer Format=#
File{:pdf}, #=Portable Document Format Requires Ghostscript to read. By default, ImageMagick sets the page size to the MediaBox. Some PDF files, however, have a CropBox or TrimBox that is smaller than the MediaBox and may include white space, registration or cutting marks outside the CropBox or TrimBox. To force ImageMagick to use the CropBox or TrimBox rather than the MediaBox, use -define (e.g. -define pdf:use-cropbox=true or -define pdf:use-trimbox=true). Use -density to improve the appearance of your PDF rendering (e.g. -density 300x300). Use -alpha remove to remove transparency. To specify direct conversion from Postscript to PDF, use -define delegate:bimodel=true. Use -define pdf:fit-page=true to scale to the page size.=#
File{:pef}, #=Pentax Electronic File Requires an explicit image format otherwise the image is interpreted as a TIFF image (e.g. pef:image.pef).=#
File{:pfa}, #=Postscript Type 1 font (ASCII) Opening as file returns a preview image.=#
File{:pfb}, #=Postscript Type 1 font (binary) Opening as file returns a preview image.=#
File{:pfm}, #=Portable float map format=#
File{:pgm}, #=Portable graymap format (gray scale)=#
File{:picon}, #=Personal Icon=#
File{:pict}, #=Apple Macintosh QuickDraw/PICT file=#
File{:pix}, #=Alias/Wavefront RLE image format=#
File{:png}, #=Portable Network Graphics Requires libpng-1.0.11 or later, libpng-1.2.5 or later recommended. The PNG specification does not support pixels-per-inch units, only pixels-per-centimeter. To avoid reading a particular associated image profile, use -define profile:skip=name (e.g. profile:skip=ICC).=#
File{:png8}, #=Portable Network Graphics 8-bit indexed with optional binary transparency=#
File{:png00}, #=Portable Network Graphics PNG inheriting subformat from original=#
File{:png24}, #=Portable Network Graphics opaque or binary transparent 24-bit RGB=#
File{:png32}, #=Portable Network Graphics opaque or transparent 32-bit RGBA=#
File{:png48}, #=Portable Network Graphics opaque or binary transparent 48-bit RGB=#
File{:png64}, #=Portable Network Graphics opaque or transparent 64-bit RGB=#
File{:pnm}, #=Portable anymap PNM is a family of formats supporting portable bitmaps (PBM) , graymaps (PGM), and pixmaps (PPM). There is no file format associated with pnm itself. If PNM is used as the output format specifier, then ImageMagick automagically selects the most appropriate format to represent the image. The default is to write the binary version of the formats. Use -compress none to write the ASCII version of the formats.=#
File{:ppm}, #=Portable pixmap format (color)=#
File{:ps}, #=Adobe PostScript file Requires Ghostscript to read. To force ImageMagick to respect the crop box, use -define (e.g. -define eps:use-cropbox=true). Use -density to improve the appearance of your Postscript rendering (e.g. -density 300x300). Use -alpha remove to remove transparency. To specify direct conversion from PDF to Postscript, use -define delegate:bimodel=true.=#
File{:ps2}, #=Adobe Level II PostScript file Requires Ghostscript to read.=#
File{:ps3}, #=Adobe Level III PostScript file Requires Ghostscript to read.=#
File{:psb}, #=Adobe Large Document Format=#
File{:psd}, #=Adobe Photoshop bitmap file=#
File{:ptif}, #=Pyramid encoded TIFF Multi-resolution TIFF containing successively smaller versions of the image down to the size of an icon.=#
File{:pwp}, #=Seattle File Works multi-image file=#
File{:rad}, #=Radiance image file Requires that ra_ppm from the Radiance software package be installed.=#
File{:raf}, #=Fuji CCD-RAW Graphic File=#
File{:rgb}, #=Raw red, green, and blue samples Use -size and -depth to specify the image width, height, and depth. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.=#
File{:rgba}, #=Raw red, green, blue, and alpha samples Use -size and -depth to specify the image width, height, and depth. To specify a single precision floating-point format, use -define quantum:format=floating-point. Set the depth to 32 for single precision floats, 64 for double precision, and 16 for half-precision.=#
File{:rfg}, #=LEGO Mindstorms EV3 Robot Graphics File=#
File{:rla}, #=Alias/Wavefront image file=#
File{:rle}, #=Utah Run length encoded image file=#
File{:sct}, #=Scitex Continuous Tone Picture=#
File{:sfw}, #=Seattle File Works image=#
File{:sgi}, #=Irix RGB image=#
File{:shtml}, #=Hypertext Markup Language client-side image map Used to write HTML clickable image maps based on a the output of montage or a format which supports tiled images such as MIFF.=#
File{:sid,}, #=R Multiresolution seamless image Requires the mrsidgeodecode command line utility that decompresses MG2 or MG3 SID image files.=#
File{:sun}, #=SUN Rasterfile=#
File{:svg}, #=Scalable Vector Graphics ImageMagick utilizes inkscape if its in your execution path otherwise RSVG. If neither are available, ImageMagick reverts to its internal SVG renderer. The default resolution is 90dpi.=#
File{:tga}, #=Truevision Targa image Also known as formats ICB, VDA, and VST.=#
File{:tiff}, #=Tagged Image File Format Also known as TIF. Requires tiff-v3.6.1.tar.gz or later. Use -define to specify the rows per strip (e.g. -define tiff:rows-per-strip=8). To define the tile geometry, use for example, -define tiff:tile-geometry=128x128. To specify a signed format, use -define quantum:format=signed. To specify a single-precision floating-point format, use -define quantum:format=floating-point. Set the depth to 64 for a double-precision floating-point format. Use -define quantum:polarity=min-is-black or -define quantum:polarity=min-is-white toggle the photometric interpretation for a bilevel image. Specify the extra samples as associated or unassociated alpha with, for example, -define tiff:alpha=unassociated. Set the fill order with -define tiff:fill-order=msb|lsb. Set the TIFF endianess with -define tiff:endian=msb|lsb. Use -define tiff:exif-properties=false to skip reading the EXIF properties. You can set a number of TIFF software attributes including document name, host computer, artist, timestamp, make, model, software, and copyright. For example, -set tiff:software "My Company". If you want to ignore certain TIFF tags, use this option: -define tiff:ignore-tags=comma-separated-list-of-tag-IDs=#
File{:tim}, #=PSX TIM file=#
File{:ttf}, #=TrueType font file Requires freetype 2. Opening as file returns a preview image. Use -set if you do not want to hint glyph outlines after their scaling to device pixels (e.g. -set type:hinting off).=#
File{:txt}, #=Raw text file=#
File{:uil}, #=X-Motif UIL table=#
File{:uyvy}, #=Interleaved YUV raw image Use -size and -depth command line options to specify width and height. Use -sampling-factor to set the desired subsampling (e.g. -sampling-factor 4:2:2).=#
File{:vicar}, #=VICAR rasterfile format=#
File{:viff}, #=Khoros Visualization Image File Format=#
File{:wbmp}, #=Wireless bitmap Support for uncompressed monochrome only.=#
File{:wdp}, #=JPEG extended range Requires the jxrlib delegate library. Put the JxrDecApp and JxrEncApp applications in your execution path.=#
File{:webp}, #=Weppy image format Requires the WEBP delegate library. Specify the encoding options with the -define option See WebP Encoding Options for more details.=#
File{:wmf}, #=Windows Metafile Requires libwmf. By default, renders WMF files using the dimensions specified by the metafile header. Use the -density option to adjust the output resolution, and thereby adjust the output size. The default output resolution is 72DPI so -density 144 results in an image twice as large as the default. Use -background color to specify the WMF background color (default white) or -texture filename to specify a background texture image.=#
File{:wpg}, #=Word Perfect Graphics File=#
File{:x}, #=display or import an image to or from an X11 server Use -define to obtain the image from the root window (e.g. -define x:screen=true). Set x:silent=true to turn off the beep when importing an image.=#
File{:xbm}, #=X Windows system bitmap, black and white only Used by the X Windows System to store monochrome icons.=#
File{:xcf}, #=GIMP image=#
File{:xpm}, #=X Windows system pixmap Also known as PM. Used by the X Windows System to store color icons.=#
File{:xwd}, #=X Windows system window dump Used by the X Windows System to save/display screen dumps.=#
File{:x3f}, #=Sigma Camera RAW Picture File=#
File{:ycbcr}, #=Raw Y, Cb, and Cr samples Use -size and -depth to specify the image width, height, and depth.=#
File{:ycbcra}, #=Raw Y, Cb, Cr, and alpha samples Use -size and -depth to specify the image width, height, and depth.=#
File{:yuv} #==#
)
FileIO.writeformats(::Type{Val{:imagemagick}}) = SUPPORTED_READ_FORMATS
end