using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))

products = [
    LibraryProduct(prefix, String["libMagickWand"], :libwand),
]

version = v"6.9.10-12"
dependencies = [
    "https://github.com/bicycle1885/ZlibBuilder/releases/download/v1.0.4/build_Zlib.v1.2.11.jl",
    "https://github.com/SimonDanisch/LibpngBuilder/releases/download/v1.0.2/build_libpng.v1.6.31.jl",
    "https://github.com/SimonDanisch/LibJPEGBuilder/releases/download/v9b/build_libjpeg.v9.0.0-b.jl",
    "https://github.com/SimonDanisch/LibTIFFBuilder/releases/download/v5/build_libtiff.v4.0.9.jl",
    "https://github.com/JuliaIO/ImageMagickBuilder/releases/download/v$(version)/build_ImageMagick.v$(version).jl"
]

for dependency in dependencies
    file = joinpath(@__DIR__, basename(dependency))
    isfile(file) || download(dependency, file)
    # it's a bit faster to run the build in an anonymous module instead of
    # starting a new julia process

    # Build the dependencies
    Mod = @eval module Anon end
    Mod.include(file)
end

# First, check to see if we're all satisfied
if any(!satisfied(p; verbose=verbose) for p in products)
    # Finally, write out a deps.jl file
    write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
end
                
open("deps.jl", "w") do io
    println(io, """
    libversion() = $(repr(version))
    const libwand = im.libwand
    function check_deps()
        zlib.check_deps()
        png.check_deps()
        jpeg.check_deps()
        tiff.check_deps()
        im.check_deps()
    end
    """)
end
                