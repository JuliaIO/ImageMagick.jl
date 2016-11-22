using ImageMagick

info("ImageMagick version ", ImageMagick.libversion)

include("constructed_images.jl")
include("readremote.jl")

FactCheck.exitstatus()
