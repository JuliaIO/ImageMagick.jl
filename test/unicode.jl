using ImageMagick, ColorTypes, FileIO
using Test

cjkchars = "\xe4\xb8\xad\xe6\x96\x87\x20\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e\x20\xed\x95\x9c\xea\xb5\xad\xec\x96\xb4"

workdir = joinpath(tempdir(), "Images")
cjkdir = joinpath(workdir, cjkchars)
if !isdir(workdir)
    mkdir(workdir)
end
if !isdir(cjkdir)
    mkdir(cjkdir)
end

@testset "Unicode compatibility" begin

    @testset "Unicode path names" begin
        img = [RGB(1, 0, 0) RGB(0, 1, 0);RGB(0, 0, 1) RGB(1, 1, 1)]
        fn = joinpath(cjkdir, cjkchars * ".png")
        x = nothing
        open(fn, "w") do io
            @test try
                ImageMagick.save(Stream(format"PNG", io), img);true
            catch
                false
            end
        end
        @test try
            x = ImageMagick.load(fn);true
        catch
            false
        end
        @test x == img
        @test try
            ImageMagick.save(fn, img);true
        catch
            false
        end
        open(fn, "r") do io
            @test try
                x = ImageMagick.load(io);true
            catch
                false
            end
            @test x == img
        end
    end

end

nothing
