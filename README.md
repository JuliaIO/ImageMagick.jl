# ImageMagick

[![Build Status](https://travis-ci.org/JuliaIO/ImageMagick.jl.svg?branch=master)](https://travis-ci.org/JuliaIO/ImageMagick.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/hl0j4amikte3pl9c/branch/master?svg=true)](https://ci.appveyor.com/project/SimonDanisch/imagemagick-jl/branch/master)
[![Coverage Status](https://coveralls.io/repos/JuliaIO/ImageMagick.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/JuliaIO/ImageMagick.jl?branch=master)
[![codecov.io](http://codecov.io/github/JuliaIO/ImageMagick.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaIO/ImageMagick.jl?branch=master)

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
