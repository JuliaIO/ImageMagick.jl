using ImageMagick, Test

img = load(joinpath("images", "bad_exif_orientation.jpg"))
@test size(img) == (512,512)
