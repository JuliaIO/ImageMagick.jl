using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))

products = [
    LibraryProduct(prefix, ["libz"], :libz),
    LibraryProduct(prefix, String["libjpeg"], :libjpeg),
    LibraryProduct(prefix, String["libpng16"], :libpng),
    LibraryProduct(prefix, String["libtiff"], :libtiff),
    LibraryProduct(prefix, String["libtiffxx"], :libtiffxx),
    LibraryProduct(prefix, String["libMagickWand"], :libwand),
]

version = v"6.9.10-12"
dependencies = [
    "https://github.com/bicycle1885/ZlibBuilder/releases/download/v1.0.4/build_Zlib.v1.2.11.jl",
    "https://github.com/SimonDanisch/LibpngBuilder/releases/download/v1.0.3/build_libpng.v1.6.37.jl",
    "https://github.com/SimonDanisch/LibJPEGBuilder/releases/download/v10/build_libjpeg.v9.0.0-b.jl",
    "https://github.com/SimonDanisch/LibTIFFBuilder/releases/download/v6/build_libtiff.v4.0.9.jl",
    "https://github.com/JuliaIO/ImageMagickBuilder/releases/download/v3/build_ImageMagick.v$(version).jl"
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

write_deps_file(joinpath(@__DIR__, "deps.jl"), products)

open("deps.jl", "a") do io
    write(io, """
    libversion() =  $(repr(version))
    """)
end
