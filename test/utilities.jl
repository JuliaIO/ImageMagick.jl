using InteractiveUtils: subtypes 
@testset "Utilities" begin 
  @testset "subtypes" begin 
    println() 
    println("---------------------------------------------------------------------------")
    println("  This next test may cause deprecation warnings.")
    println("  Remove this note if it stops doing that and remove the  function.")
    println("    _subtypes_and_avoid_deprecation ")
    println("  function from libmagickwand.jl.")
    println("---------------------------------------------------------------------------")
    println() 
    @test subtypes(Integer) == ImageMagick._subtypes_and_avoid_deprecation(Integer) 
    @test subtypes(ImageMagick.ColorAlpha) == ImageMagick._subtypes_and_avoid_deprecation(ImageMagick.ColorAlpha)
    @test subtypes(ImageMagick.AlphaColor) == ImageMagick._subtypes_and_avoid_deprecation(ImageMagick.AlphaColor)
  end 
end 