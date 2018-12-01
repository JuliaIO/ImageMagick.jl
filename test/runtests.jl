using ImageMagick, ColorVectorSpace, ImageMetadata, ImageTransformations

using Random: bitrand
using Base.CoreLogging: SimpleLogger, with_logger
using Pkg

function is_ci()
    get(ENV, "TRAVIS", "") == "true" ||
    get(ENV, "APPVEYOR", "") in ("true", "True") ||
    get(ENV, "CI", "") in ("true", "True")
end

@info "ImageMagick version ", ImageMagick.libversion()

include("constructed_images.jl")
include("readremote.jl")
include("badimages.jl")
include("unicode.jl")

workdir = joinpath(tempdir(), "Images")
try
    rm(workdir, recursive=true)
catch
end
