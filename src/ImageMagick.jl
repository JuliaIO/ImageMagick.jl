module ImageMagick

using Requires
importall FileIO

# Define the Backend Name
global const BACKEND = Val{:imagemagick}
# Include the supported formats first, so they are immidiately availabl
include("supported_formats.jl")
# lazyly load the core modules
@lazymod ImageMagickIO "imageio_interface.jl"

#just if read is actually used, load the full IO module
FileIO.read(file::readformats(BACKEND), ::Type{BACKEND}) = imagemagickio().imagemagickread(abspath(file))


end # module
