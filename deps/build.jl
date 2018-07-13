using BinaryProvider # requires BinaryProvider 0.3.0 or later


dependencies = [
    "build_Zlib.v1.2.11.jl",
    "build_libpng.v1.0.0.jl",
    "build_libjpeg.v9.0.0-b.jl",
    "build_libtiff.v4.0.9.jl"
]

for elem in dependencies
    # it's a bit faster to run the build in an anonymous module instead of
    # starting a new julia process
    m = Module(:__anon__)
    Core.include(m, (joinpath(@__DIR__, elem)))
end

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libMagickWand"], :libwand),
]
# Download binaries from hosted location
version = v"6.9.10-4"

bin_prefix = "https://github.com/JuliaIO/ImageMagickBuilder/releases/download/v$version"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/ImageMagick.v$version.aarch64-linux-gnu.tar.gz", "8780c6eec7f2c34dc35355fdb332e5c0fcd021105293e8e4f6b6e75032e35b97"),
    Linux(:aarch64, :musl) => ("$bin_prefix/ImageMagick.v$version.aarch64-linux-musl.tar.gz", "629a373cf7990232b8272024aa649bd44443930706c43c060b1b384913b840f7"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/ImageMagick.v$version.arm-linux-gnueabihf.tar.gz", "4b5500f31a8fcf89137f9ca40ebd60bdb3499cdc8eab4e321a1429c61b3ecd45"),
    Linux(:armv7l, :musl, :eabihf) => ("$bin_prefix/ImageMagick.v$version.arm-linux-musleabihf.tar.gz", "2232234af05d29c85378d589e04f29b38c35e05d25d6c732f7a01a9ff394a0f2"),
    Linux(:i686, :glibc) => ("$bin_prefix/ImageMagick.v$version.i686-linux-gnu.tar.gz", "34db87e26bff290dedec73394e8266aaaaca816984513b57766c933cf6ec1a26"),
    Linux(:i686, :musl) => ("$bin_prefix/ImageMagick.v$version.i686-linux-musl.tar.gz", "64d9c1867ed370407adfae04ed7ef48bfe5f29ba843069b5c76299bd5a5da155"),
    Windows(:i686) => ("$bin_prefix/ImageMagick.v$version.i686-w64-mingw32.tar.gz", "382bc4d3c9e709711eafa2aa795eb3ba1c88dacefb6932ef32c44675a4b11132"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/ImageMagick.v$version.powerpc64le-linux-gnu.tar.gz", "4ba60630e955f6c7fe952c21d5ea403bfe3725cdd3e7730937dc604f6c33ceb7"),
    MacOS(:x86_64) => ("$bin_prefix/ImageMagick.v$version.x86_64-apple-darwin14.tar.gz", "b4e6b9a32e1ebaf314295fb569022014f64de0f25518f1fbea1f2588a94cbe28"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/ImageMagick.v$version.x86_64-linux-gnu.tar.gz", "908fd88a0e52f038f3f19d192036df3c325d8560a8290a5abb9bd2d9307d8aa8"),
    Linux(:x86_64, :musl) => ("$bin_prefix/ImageMagick.v$version.x86_64-linux-musl.tar.gz", "d7c083bf912cedff59cfac4740c9a15977882c92896f181dd7114f3d5508a126"),
    FreeBSD(:x86_64) => ("$bin_prefix/ImageMagick.v$version.x86_64-unknown-freebsd11.1.tar.gz", "ca8f099f7c3639e4063213ac00a17a72b01f45a6713ec2306cd5af5d9398f989"),
    Windows(:x86_64) => ("$bin_prefix/ImageMagick.v$version.x86_64-w64-mingw32.tar.gz", "c3d0d85f0c44ae3d10b42a80514a62ea566b84d30feaf9dbe574bb73aa41b085"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps_im.jl"), products)

function include_deps(name)
    """
    module $name
        import Libdl
        path = joinpath(@__DIR__, $(repr(string("deps_", name, ".jl"))))
        isfile(path) || error("$name wasn't build correctly. Please run Pkg.build(\\\"ImageMagick\\\")")
        include(path)
    end
    using .$name
    """
end

open("deps.jl", "w") do io
    for dep in (:zlib, :png, :jpeg, :tiff, :im)
        println(io, include_deps(dep))
    end
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
