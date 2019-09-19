# ImageMagick

| **Platform**                                                               | **Build Status**                                                                                |
|:-------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------:|
| Linux & MacOS x86 | [![][travis-img]][travis-url] |
| Windows 32/64-bit | [![][appveyor-img]][appveyor-url] |
| Linux ARM 32/64-bit | [![][drone-img]][drone-url] |
| FreeBSD x86 | [![][cirrus-img]][cirrus-url] |
|  | [![Codecoverage Status][codecov-img]][codecov-url]<br>[![Coveralls Status][coveralls-img]][coveralls-url] |


This package provides a wrapper around
[ImageMagick](http://www.imagemagick.org/) version 6.  It was split off from
[Images.jl](https://github.com/timholy/Images.jl) to make image I/O more
modular.

# Installation

Add the package with

```julia
Pkg.add("ImageMagick")
```

# Usage

ImageMagick will be used as needed if you've said

```julia
using FileIO
```

in your session or module. You should **not** generally say `using
ImageMagick`.  See [FileIO](https://github.com/JuliaIO/FileIO.jl) for
further details.

It's worth pointing out that packages such as [Images.jl](https://github.com/JuliaImages/Images.jl) load FileIO for you.

Loading an image is then as simple as

```julia
img = load(filename[; view=false])
```

Set `view=true` to reduce memory consumption when loading large files, possibly
at some slight cost in terms of performance of future operations.


# Troubleshooting

## OSX

ImageMagick.jl will use the system-wide libMagicWand in `/usr/local/lib` if it is
present.  Use the environment variable `MAGICK_HOME` to add other paths to the search
path. Note that version 6.7+ (up to but not including 7.0) are the most supported versions, in
particular for multipage TIFFs.  Use `ImageMagick.libversion` to see what version the installer
found.  If ImageMagick.jl doesn't find a previous installation, it will install its own copy of the
ImageMagick library with Homebrew.jl.

ImageMagick.jl 0.3.0 introduced significant improvements in the installation procedure for OSX users.
If you've had trouble with previous versions of ImageMagick.jl and attempted to resolve problems manually,
some of your workarounds might interfere with the new approach. You can reset your build with

```julia
using Homebrew
Homebrew.rm("imagemagick@6")
Homebrew.brew(`prune`)
Pkg.build("ImageMagick")
```

You may also find [debugging
Homebrew](https://github.com/JuliaLang/Homebrew.jl/wiki/Debugging-Homebrew.jl)
useful.

Finally, an alternative to ImageMagick on OS X is
[QuartzImageIO](https://github.com/JuliaIO/QuartzImageIO.jl).


## Manual installation on Windows

If automatic installation fails, get the current version from
http://www.imagemagick.org/script/binary-releases.php#windows
(e.g. ImageMagick-6.8.8-7-Q16-x86-dll.exe) and make sure that the "Install
development headers and libraries for C and C++" checkbox is selected.  You may
choose to let the installer add the installation directory to the system path or
provide it separately.  In the later case you may add it to your `.juliarc.jl`
file as (for example) `push!(Base.DL_LOAD_PATH,
"C:/programs/ImageMagick-6.8.8"`). Alternatively, you can set your `MAGICK_HOME` environment variable.

**When manual intervention is necessary, you need to restart Julia for the
necessary changes to take effect.**

## Linux

ImageMagick.jl automatically searches for an installed version of
libMagickWand.  Use the environment variable `MAGICK_HOME` to add to the search
path.  Use `ImageMagick.libversion()` to see what version it found.  Version 6.7+
(up to but not including 7.0) are the most supported versions, in particular
for multipage TIFFs.

The environment variable `MAGICK_THREAD_LIMIT` can be used to throttle multithreading.

[discourse-tag-url]: https://discourse.julialang.org/tags/yolo

[travis-img]: https://travis-ci.com/JuliaIO/ImageMagick.jl.svg?branch=master
[travis-url]: https://travis-ci.com/JuliaIO/ImageMagick.jl

[appveyor-img]: https://ci.appveyor.com/api/projects/status/hl0j4amikte3pl9c/branch/master?svg=true
[appveyor-url]: https://ci.appveyor.com/project/SimonDanisch/imagemagick-jl/branch/master

[drone-img]: https://cloud.drone.io/api/badges/JuliaIO/ImageMagick.jl/status.svg
[drone-url]: https://cloud.drone.io/JuliaIO/ImageMagick.jl

[cirrus-img]: https://api.cirrus-ci.com/github/JuliaIO/ImageMagick.jl.svg
[cirrus-url]: https://cirrus-ci.com/github/JuliaIO/ImageMagick.jl

[codecov-img]: https://codecov.io/gh/JuliaIO/ImageMagick.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/JuliaIO/ImageMagick.jl

[coveralls-img]: https://coveralls.io/repos/github/JuliaIO/ImageMagick.jl/badge.svg?branch=master
[coveralls-url]: https://coveralls.io/github/JuliaIO/ImageMagick.jl?branch=master

[issues-url]: https://github.com/JuliaIO/ImageMagick.jl/issues
