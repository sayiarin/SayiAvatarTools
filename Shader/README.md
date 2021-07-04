# Shaders
So I jumped onto the bandwaggon and made some shader myself. They're all very basic and specific to my own usecase but maybe they are helpful for someone else out there too.

# Pixelation
The Pixelation shader does exactly as the name implies: pixelating stuff. I use it on an icosphere around my hand that I can toggle to censor things. :>

To change how drastic the pixelation is you can change the resolution by setting the pixel size in unity units per axis.

# Three Colour Gradient
A simple shader that blends between three different colours. It is unlit meaning it doens't get affected by lighting, which makes it good for being used on an avatars pen.

It uses HDR Colours so you can make it glow in worlds with Bloom enabled in the PostProcessing and you have a few convenient sliders to control how the gradient transitions from one colour to another.

# SayiToon
A relatively simple Toon Shader I made to learn more about shaders in general and to have more control over how my VRC Avatar looks.

## Features:
To see a short video preview of this shader, please have a look into the Examples folder and open the sayitoon-showcase.webm file.

### Variants:
There is an Unlit and a Lit variant of the shader. Both also have a simplified variant that instead of a texture array takes in only one main texture.

A transparent variant exists as well based on the simplified variant of the lit and unlit shader.

### 1. "Normal" vs "Simple" Variants
The normal variants of the shader take a Texture Array and an index as parameter to determine what is being rendered. You can use my TextureArrayManager to make working with those easier.

A Fallback Texture can be added to have a decent looking avatar for people that don't have your shader shown.

The simple variants are basically the same except they only take in one single texture instead of texture arrays.

### Shading
Lit Variants are always affected by Lightprobes, but the shading is flat. Shadows from Directional Light can be enabled. The shader also allows you to use a shadow ramp texture for directional light shadows.

Unlit Variants can have fake shadows using a shadow ramp and a vector to set the direction of the fake light.

An example of what a shadow ramp looks like can be found in the Examples folder of this repository.

### Material and Feature Masks
To apply certain effects of the shader only to specific parts you have the ability to provide Textures that will map different colour channels to different features.

#### Material Feauture Mask:
* Red Channel = Reflection/Smoothness
* Green Channel = Specular Highlights (not yet supported)
* Blue Channel = Height Map (not yet supported)

#### Special Effects Feature Mask
* Red Channel = HSV changes
* Green Channel = Wireframe
* Blue Channel = "psychadelic" Effect

### Reflections
A Black and White texture can be supplied to the shader as a reflection map. The higher the value the stronger the effect, meaning you can have gray values between completely black or completely white to change how much a specific area is affected by the Smoothness and Reflectiveness settings.

### Outline
The outline effect, if enabled, will create an outline around your avatar. You can specify an HDR colour and modify the width of the outline.

### Wireframe
If enabled will show a wireframe (triangles) on your mesh. Their colour can be set to an HDR colour and will blend between that colour and a colour automatically determined by the triangles orientation depending on the HDR colours alpha value.

The maximum width of the wireframe is adjustable. The wireframes width will scale with distance, meaning when someone gets closer the lines smoothly turn thinner as to not cover up the whole texture.

A Fade Out Distance can be set at which the wireframe fades out. This is done to counteract the strong aliasing that can occur on the thin lines when looked at from a distance. If you don't like it just set the Distance to a high value.

### HSV Settings
Hue, Saturation and Value (Intensity) of your texture can be changed with a few simple sliders. You can provide a Black and White Texture that acts as a mask. Black parts will not be affected by the HSV sliders.

### Glow Effect
You can enable a glow effect. Supply a Texture with a transparent background and the parts that you want to glow with colour. These will light up and, if in a world with bloom enabled, glow. There are settings to change the Intensity and enable an automatic colour transition over time.

## Planned features:
Nothing is specifically planned, but I intend to add least the following over time:
* add Texture Array support for Glow and Reflection Map on the "complex" variants
* Acid/LSD effect on masked area
* normal/height map support
* specularity
* rimlight
* whatever else I randomly come accross and might be cool to have