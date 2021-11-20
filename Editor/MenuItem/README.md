# Menu Items

## CreateTexture2DArrayFromSelection

Creates a Texture2DArray based on the current selection. It will disregard any non Texture2D assets selected and will only generate the new Asset if all selected Textures have the same Dimensions and Format.

The generated File will be called `GeneratedTexture2DArray.asset`.

## GeneratePerlinNoiseTexture

Generates a perlin noise texture with at the selected dimension. Right now very rudimentary.