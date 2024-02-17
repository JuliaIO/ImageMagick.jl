# ImageMagick

| **Platform**                                                               | **Build Status**                                                                                |
|:-------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------:|
| Linux & MacOS & Windows | [![Github Action][github-action-img]][github-action-url] |

[![Codecoverage Status][codecov-img]][codecov-url] [![Coveralls Status][coveralls-img]][coveralls-url]

This package provides a wrapper around
[ImageMagick](http://www.imagemagick.org/) version 6.  It was split off from
[Images.jl](https://github.com/timholy/Images.jl) to make image I/O more
modular.

## Installation

Add the package with

```julia
Pkg.add("ImageMagick")
```

## Usage

After installation, ImageMagick will be used as needed if you've said

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

## Advanced usage

The environment variable `MAGICK_THREAD_LIMIT` can be used to throttle multithreading.

[github-action-img]: https://github.com/JuliaIO/ImageMagick.jl/actions/workflows/CI.yml/badge.svg
[github-action-url]: https://github.com/JuliaIO/ImageMagick.jl/actions/workflows/CI.yml

[cirrus-img]: https://api.cirrus-ci.com/github/JuliaIO/ImageMagick.jl.svg
[cirrus-url]: https://cirrus-ci.com/github/JuliaIO/ImageMagick.jl

[codecov-img]: https://codecov.io/gh/JuliaIO/ImageMagick.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/JuliaIO/ImageMagick.jl

[coveralls-img]: https://coveralls.io/repos/github/JuliaIO/ImageMagick.jl/badge.svg?branch=master
[coveralls-url]: https://coveralls.io/github/JuliaIO/ImageMagick.jl?branch=master
