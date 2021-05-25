# Shaders
So I jumped onto the bandwaggon and made some shader myself. They're all very basic and specific to my own usecase but maybe they are helpful for someone else out there too.

## Pixelation
The Pixelation shader does exactly as the name implies: pixelating stuff. I use it on an icosphere around my hand that I can toggle to censor things. :>

To change how drastic the pixelation is you can change the resolution by setting the pixel size in unity units per axis.

## GradientTrail
A simple shader that blends between three different colours. It is unlit meaning it doens't get affected by lighting, which makes it good for being used on an avatars pen.

It uses HDR Colours so you can make it glow in worlds with Bloom enabled in the PostProcessing and you have a few convenient sliders to manipulate how the gradient transitions from one colour to another.

## SayiToon
Planned to be a basic toon shader with some features that cover my needs. Very much _work in progress_ right now.