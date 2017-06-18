using BinDeps

@BinDeps.setup


const MIN_VERSION = v"6.0-" # First supported version
const MAX_VERSION = v"7.0-" # First unsupported version

# Set the environment variables required by some providers during the pre-init version validation.
function check_version(lib, handle)
    if (is_apple() && startswith(lib, homebrew_prefix))
        version = withenv(homebrew_envs...) do
            preinit_libversion(lib, handle)
        end
    elseif (is_windows() && startswith(lib, magick_libdir))
        version = withenv(windows_binary_envs...) do
            preinit_libversion(lib, handle)
        end
    else
        version = preinit_libversion(lib, handle)
    end

    return version >= MIN_VERSION && version < MAX_VERSION
end

function preinit_libversion(lib, handle)
    MagickQueryConfigureOption = Libdl.dlsym_e(handle, :MagickQueryConfigureOption)
    p = ccall(MagickQueryConfigureOption, Ptr{UInt8}, (Ptr{UInt8},), "LIB_VERSION_NUMBER")
    p != C_NULL || error("Error obtaining ImageMagick library version.")
    return VersionNumber(join(split(unsafe_string(p), ',')[1:3], '.'))
end


libnames    = ["libMagickWand", "CORE_RL_wand_"]
suffixes    = ["", "-Q16", "-6.Q16", "-Q8"]
options     = ["", "HDRI"]
extensions  = ["", ".so.2", ".so.4", ".so.5"]
aliases     = vec(libnames .*
                  reshape(suffixes, (1, length(suffixes))) .*
                  reshape(options, (1, 1, length(options))) .*
                  reshape(extensions, (1, 1, 1, length(extensions))))
libwand     = library_dependency("libwand", aliases = aliases, validate = check_version)


mpath = get(ENV, "MAGICK_HOME", "") # If MAGICK_HOME is defined, add to library search path
if !isempty(mpath)
    provides(Binaries, mpath, libwand)
    provides(Binaries, joinpath(mpath, "lib"), libwand)
end


if is_linux()
    provides(AptGet, "libmagickwand4", libwand)
    provides(AptGet, "libmagickwand5", libwand)
    provides(AptGet, "libmagickwand-6.q16-2", libwand)
    provides(Pacman, "imagemagick", libwand)
    provides(Yum, "ImageMagick", libwand)
end


if is_windows()
    push!(BinDeps.defaults, BuildProcess) # TODO: remove me when upstream is fixed

    OS_ARCH = Sys.WORD_SIZE == 64 ? "x64" : "x86"

    # TODO: checksums: we have gpg
    # Extract the appropriate filename to download
    magick_base = "http://www.imagemagick.org/download/binaries"
    binariesfn  = download(magick_base)
    str         = readstring(binariesfn)
    pattern     = "ImageMagick-6.9.*?-Q16-$(OS_ARCH)-dll.exe"
    magick_exe  = String(match(Regex(pattern), str).match)

    magick_tmpdir = BinDeps.downloadsdir(libwand)
    magick_url    = "$(magick_base)/$(magick_exe)"
    magick_installdir = joinpath(BinDeps.libdir(libwand), OS_ARCH)
    magick_libdir = joinpath(magick_installdir, "{app}")
    innounp_url   = "https://bintray.com/artifact/download/julialang/generic/innounp.exe"

    windows_binary_envs =
        Dict("MAGICK_CONFIGURE_PATH" => magick_libdir,
             "MAGICK_CODER_MODULE_PATH" => joinpath(magick_libdir, "modules", "coders"),
             "MAGICK_FILTER_MODULE_PATH" => joinpath(magick_libdir, "modules", "filters"),
             "PATH" => magick_libdir * ";" * ENV["PATH"])
    preloads = string("function initenv()\n",
                      [string("    ENV[\"", k, "\"] = \"", escape_string(v), "\"\n") for (k, v) in windows_binary_envs]...,
                      "end\n")

    provides(BuildProcess,
        (@build_steps begin
            FileDownloader(magick_url, joinpath(magick_tmpdir, magick_exe))
            FileDownloader(innounp_url, joinpath(magick_tmpdir, "innounp.exe"))
            @build_steps begin
                ChangeDirectory(magick_tmpdir)
                `innounp.exe -q -y -b -x -d$(magick_installdir) $(magick_exe)`
            end
        end),
        libwand, os = :Windows, unpacked_dir = magick_libdir, preload = preloads)
end


if is_apple()
    using Homebrew
    homebrew_prefix = Homebrew.prefix()
    homebrew_envs =
        Dict("MAGICK_CONFIGURE_PATH" => joinpath(homebrew_prefix, "opt", "imagemagick@6", "lib",
                "ImageMagick", "config-Q16"),
             "MAGICK_CODER_MODULE_PATH" => joinpath(homebrew_prefix, "opt", "imagemagick@6", "lib",
                "ImageMagick", "modules-Q16", "coders"),
             "MAGICK_FILTER_MODULE_PATH" => joinpath(homebrew_prefix, "opt", "imagemagick@6",
                "lib", "ImageMagick", "modules-Q16", "filters"),
             "ENV" => joinpath(homebrew_prefix, "opt", "imagemagick@6", "bin") * ":" * ENV["PATH"])
    preloads = string("function initenv()\n",
                      [string("    ENV[\"", k, "\"] = \"", escape_string(v), "\"\n") for (k, v) in homebrew_envs]...,
                      "end\n")
    provides(Homebrew.HB, "homebrew/core/imagemagick@6", libwand, os = :Darwin, preload = preloads)
end


@BinDeps.install Dict([(:libwand, :libwand)])


is_windows() && pop!(BinDeps.defaults)
