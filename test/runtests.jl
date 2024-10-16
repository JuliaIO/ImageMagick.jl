using ImageMagick, ImageMetadata, ImageTransformations

using Random: bitrand
using Base.CoreLogging: SimpleLogger, with_logger

include("constructed_images.jl")
include("readremote.jl")
include("badimages.jl")
include("unicode.jl")
include("utilities.jl")

workdir = joinpath(tempdir(), "Images")
try
    rm(workdir, recursive=true)
catch
end
