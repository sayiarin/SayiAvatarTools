#include "ColourUtilities.cginc"
#include "Wireframe.cginc"
#include "Reflection.cginc"
#include "LightUtilities.cginc"
#include "WorldPosTexture.cginc"

float4 FragmentFunction (Interpolators fragIn) : SV_TARGET
{
    float4 colour;
    // get currently active texture from array as colour that will be output at the end
    colour = UNITY_SAMPLE_TEX2DARRAY(_BaseTextures, float3(fragIn.uv, _TextureIndex));

    float4 specialEffectsFeatureMask = tex2D(_SpecialFeatureMask, fragIn.uv);

    // colour inverion is just 1 - colour
    colour.rgb = lerp(colour.rgb, 1 - colour.rgb, _InvertColours * specialEffectsFeatureMask.a);
    
    // hsv stuff, using red channel of feature mask
    float4 rgbNew = ApplyHSVChangesToRGB(colour, float3(_HueShift, _SaturationValue - 1, _ColourValue - 1));
    colour = lerp(colour, rgbNew, specialEffectsFeatureMask.r);

    // apply lighting
    colour.rgb *= CorrectedLightColour(fragIn);

    #ifdef UNITY_PASS_FORWARDBASE
        float3 materialFeatureMask = tex2D(_MaterialFeatureMask, fragIn.uv);

        // specular highlights, using blinn phong
        float3 specularLight = SpecularLight(fragIn.vertexNormal, fragIn.viewDirection, colour);
        colour.rgb = lerp(colour.rgb, specularLight, materialFeatureMask.g);
        
        // apply world space aligned 2d texture
        float3 alignedWorldPosTexture = GetAlignedWorldPosTexture(fragIn);
        colour.rgb = lerp(colour.rgb, alignedWorldPosTexture, materialFeatureMask.b * _EnableWorldPosTexture);

        // reflection using red channel
        float3 reflectionValue = GetReflection(fragIn);
        reflectionValue = lerp(colour.rgb, reflectionValue, _Reflectiveness);
        colour.rgb = lerp(colour.rgb, reflectionValue, materialFeatureMask.r);
        colour.a = lerp(colour.a, 1.0, _ReflectionIgnoresAlpha * colour.rgb);

        // glowwy
        float4 glowColour = float4(0, 0, 0, 0);
        glowColour = tex2D(_GlowTexture, fragIn.uv);
        float glowHueShift = lerp(0, (_Time.y / _GlowSpeed), _EnableGlowColourChange);
        glowColour = ApplyHSVChangesToRGB(glowColour, float3(glowHueShift, 0, _GlowIntensity));
        colour = lerp(colour, glowColour, glowColour.a * _EnableGlow);

        // wireframe
        #if SAYI_TRANSPARENT
            float4 wireframeColour = ApplyWireframeColour(colour, fragIn, specialEffectsFeatureMask.g, _EnableWireframe);
            colour = lerp(wireframeColour, wireframeColour * colour.a, _MainColourAlphaAffectsWireframe);
        #else
            colour = ApplyWireframeColour(colour, fragIn, specialEffectsFeatureMask.g, _EnableWireframe);
        #endif

        // rainbow colour effect
        // for now just a colour change over time based on normal direction, nothing fancy
        // but it looks neat
        float4 rainbowColour = float4(sin(normalize(fragIn.worldNormal).xyz * _RainbowWaveSize), 1) * 0.5 + 0.5;
        rainbowColour = ApplyHSVChangesToRGB(rainbowColour, float3(_Time.y / _RainbowSpeed, 0, 0));
        colour = lerp(colour, rainbowColour, specialEffectsFeatureMask.b * _EnableRainbowEffect);

        // colour inversion
    #endif

    colour *= _OverallBrightness;
    
    return colour;
}