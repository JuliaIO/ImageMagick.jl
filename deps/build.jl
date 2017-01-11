using BinDeps
using Compat
import Compat.String

@BinDeps.setup

libnames    = ["libMagickWand", "CORE_RL_wand_"]
suffixes    = ["", "-Q16", "-6.Q16", "-Q8"]
options     = ["", "HDRI"]
extensions  = ["", ".so.2", ".so.4", ".so.5"]
aliases     = vec(libnames .*
                  reshape(suffixes,(1,length(suffixes))) .*
                  reshape(options,(1,1,length(options))) .*
                  reshape(extensions,(1,1,1,length(extensions))))
libwand     = library_dependency("libwand", aliases = aliases)

initfun = """
function init_deps()
    ccall((:MagickWandGenesis,libwand), Void, ())
end
"""

mpath = get(ENV, "MAGICK_HOME", "") # If MAGICK_HOME is defined, add to library search path
if !isempty(mpath)
    provides(Binaries, mpath, libwand)
    provides(Binaries, joinpath(mpath,"lib"), libwand)
end

if is_linux()
    kwargs = Any[(:onload, initfun)]
    provides(AptGet, "libmagickwand4", libwand; kwargs...)
    provides(AptGet, "libmagickwand5", libwand; kwargs...)
    provides(AptGet, "libmagickwand-6.q16-2", libwand; kwargs...)
    provides(Pacman, "imagemagick", libwand; kwargs...)
    provides(Yum, "ImageMagick", libwand; kwargs...)
end

# TODO: remove me when upstream is fixed
is_windows() && push!(BinDeps.defaults, BuildProcess)

if is_windows()
    const OS_ARCH = (WORD_SIZE == 64) ? "x64" : "x86"

    # TODO: checksums: we have gpg
    # Extract the appropriate filename to download
    magick_base = "http://www.imagemagick.org/download/binaries"
    binariesfn  = download(magick_base)
    str         = readstring(binariesfn)
    pattern     = "ImageMagick-6.9.*?-Q16-$(OS_ARCH)-dll.exe"
    m           = match(Regex(pattern), str)
    magick_exe  = convert(String, m.match)

    magick_tmpdir   = BinDeps.downloadsdir(libwand)
    magick_url      = "$(magick_base)/$(magick_exe)"
    magick_libdir   = joinpath(BinDeps.libdir(libwand), OS_ARCH)
    innounp_url     = "https://bintray.com/artifact/download/julialang/generic/innounp.exe"
    initfun         =
"""
function init_deps()
    ENV["MAGICK_CONFIGURE_PATH"]    = \"$(escape_string(magick_libdir))\"
    ENV["MAGICK_CODER_MODULE_PATH"] = \"$(escape_string(magick_libdir))\"
end
init_deps()
"""

    provides(BuildProcess,
        (@build_steps begin
            CreateDirectory(magick_tmpdir)
            CreateDirectory(magick_libdir)
            FileDownloader(magick_url, joinpath(magick_tmpdir, magick_exe))
            FileDownloader(innounp_url, joinpath(magick_tmpdir, "innounp.exe"))
            @build_steps begin
                ChangeDirectory(magick_tmpdir)
                info("Installing ImageMagick library")
                `innounp.exe -q -y -b -e -x -d$(magick_libdir) $(magick_exe)`
            end
        end),
        libwand, os = :Windows, unpacked_dir = magick_libdir, preload = initfun)
end

if is_apple()
    using Homebrew
    initfun_homebrew =
"""
function init_deps()
    ENV["MAGICK_CONFIGURE_PATH"] = joinpath("$(Homebrew.prefix("imagemagick"))","lib","ImageMagick","config-Q16")
    ENV["MAGICK_CODER_MODULE_PATH"] = joinpath("$(Homebrew.prefix("imagemagick"))", "lib","ImageMagick","modules-Q16","coders")
    ENV["PATH"] = joinpath("$(Homebrew.prefix("imagemagick"))", "bin") * ":" * ENV["PATH"]
    ccall((:MagickWandGenesis,libwand), Void, ())
end
"""
    provides( Homebrew.HB, "imagemagick", libwand, os = :Darwin, preload = initfun_homebrew, onload="init_deps()")

    if success(`brew list imagemagick`) 
        brew_config = readlines(`brew config`);
        idx = findfirst(x->startswith(x,"HOMEBREW_PREFIX"), brew_config)
        brew_config[idx][18:end-1]
        homebrew_prefix = brew_config[idx][18:end-1]

        initfun_system_homebrew =
"""
function init_deps()
    ENV["MAGICK_CONFIGURE_PATH"] = joinpath($(homebrew_prefix),"lib","ImageMagick","config-Q16")
    ENV["MAGICK_CODER_MODULE_PATH"] = joinpath($(homebrew_prefix), "lib","ImageMagick","modules-Q16","coders")
    ENV["PATH"] = joinpath($(homebrew_prefix), "bin") * ":" * ENV["PATH"]
    ccall((:MagickWandGenesis,libwand), Void, ())
end
"""
        provides(Binaries, homebrew_prefix, libwand, os = :Darwin, preload = initfun_system_homebrew, onload="init_deps()")
    end
end

@BinDeps.install Dict([(:libwand, :libwand)])

# Hack-fix for issue #12
# Check to see whether init_deps is present, and if not add it
if isempty(search(readstring(joinpath(dirname(@__FILE__),"deps.jl")), "init_deps"))
    open("deps.jl", "a") do io
        write(io, initfun)
    end
end

# Save the library version; by checking this now, we avoid a runtime dependency on libwand
# See https://github.com/timholy/Images.jl/issues/184#issuecomment-55643225
module CheckVersion
using Compat
include("deps.jl")
p = ccall((:MagickQueryConfigureOption, libwand), Ptr{UInt8}, (Ptr{UInt8},), "LIB_VERSION_NUMBER")
vstr = string("v\"", join(split(unsafe_string(p), ',')[1:3], '.'), "\"")
open(joinpath(dirname(@__FILE__),"versioninfo.jl"), "w") do file
    write(file, "const libversion = $vstr\n")
end
end

is_windows() && pop!(BinDeps.defaults)
