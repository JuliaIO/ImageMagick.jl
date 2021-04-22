using ImageMagick, ImageMetadata, ImageTransformations

using Random: bitrand
using Base.CoreLogging: SimpleLogger, with_logger
using Pkg

include("constructed_images.jl")
include("readremote.jl")
include("badimages.jl")

workdir = joinpath(tempdir(), "Images")
try
    rm(workdir, recursive=true)
catch
end
