# Custom Inspectors

## TextureArrayManagerEditor

A custom Editor for [CreateTexture2DArrayFromSelection.cs](../MenuItem/CreateTexture2DArrayFromSelection.cs).

This allows for a much nicer workflow when working with Texture2DArrays because this object will keep references to the original images and the array size and content can be changed at will.

If no Texture2DArray exists yet this tool will create one. Existing ones are referenced here as well and will be properly overwriten while keeping references on other objects intact.