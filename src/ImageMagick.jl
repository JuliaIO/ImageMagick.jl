module ImageMagick

import Base: error, size

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

end # module

using ImageMagick
