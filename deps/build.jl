using BinDeps

@BinDeps.setup

libnames    = ["libMagickWand", "CORE_RL_wand_"]
suffixes    = ["", "-Q16", "-6.Q16", "-Q8"]
options     = ["", "HDRI"]
extensions  = ["", ".so.2", ".so.4", ".so.5"]
aliases     = vec(libnames .*
                  reshape(suffixes, (1, length(suffixes))) .*
                  reshape(options, (1, 1, length(options))) .*
                  reshape(extensions, (1, 1, 1, length(extensions))))
libwand     = library_dependency("libwand", aliases = aliases)


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

    const OS_ARCH = Sys.WORD_SIZE == 64 ? "x64" : "x86"

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
    preloads         =
        """
        init_envs["MAGICK_CONFIGURE_PATH"]    = \"$(escape_string(magick_libdir))\"
        init_envs["MAGICK_CODER_MODULE_PATH"] = \"$(escape_string(magick_libdir))\"
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
        libwand, os = :Windows, unpacked_dir = magick_libdir, preload = preloads)
end


if is_apple()
    using Homebrew
    homebrew_prefix = Homebrew.prefix()
    preloads =
        """
        init_envs["MAGICK_CONFIGURE_PATH"] = joinpath("$(homebrew_prefix)",
                                                      "lib", "ImageMagick", "config-Q16")
        init_envs["MAGICK_CODER_MODULE_PATH"] = joinpath("$(homebrew_prefix)",
                                                         "lib", "ImageMagick", "modules-Q16", "coders")
        init_envs["PATH"] = joinpath("$(homebrew_prefix)", "bin") * ":" * ENV["PATH"]
        """
    provides(Homebrew.HB, "homebrew/core/imagemagick@6", libwand, os = :Darwin, preload = preloads)
end


@BinDeps.install Dict([(:libwand, :libwand)])


is_windows() && pop!(BinDeps.defaults)
