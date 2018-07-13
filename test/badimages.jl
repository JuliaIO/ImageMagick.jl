using ImageMagick, Test

img = load(joinpath(@__DIR__,"images", "bad_exif_orientation.jpg"))
@test size(img) == (512,512)
