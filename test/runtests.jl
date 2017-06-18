using ImageMagick

info("ImageMagick version ", ImageMagick.libversion())

include("constructed_images.jl")
include("readremote.jl")

workdir = joinpath(tempdir(), "Images")
try
    rm(workdir, recursive=true)
end
