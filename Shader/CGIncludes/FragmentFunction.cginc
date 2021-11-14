#include "ColourUtilities.cginc"
#include "Wireframe.cginc"
#include "Reflection.cginc"
#include "LightUtilities.cginc"

float4 FragmentFunction (Interpolators fragIn) : SV_TARGET
{
    float4 colour;
    #ifdef _SIMPLE
        colour = tex2D(_MainTex, fragIn.uv);
    #else
        // get currently active texture from array as colour that will be output at the end
        colour = UNITY_SAMPLE_TEX2DARRAY(_BaseTextures, float3(fragIn.uv, _TextureIndex));
    #endif

    float4 specialEffectsFeatureMask = tex2D(_SpecialFeatureMask, fragIn.uv);
    float3 materialFeatureMask = tex2D(_MaterialFeatureMask, fragIn.uv);

    // colour inverion is just 1 - colour
    colour.rgb = lerp(colour.rgb, 1 - colour.rgb, _InvertColours * specialEffectsFeatureMask.a);
    
    // hsv stuff, using red channel of feature mask
    float4 rgbNew = ApplyHSVChangesToRGB(colour, float3(_HueShift, _SaturationValue - 1, _ColourValue - 1));
    colour = lerp(colour, rgbNew, specialEffectsFeatureMask.r);

    // apply lighting
    colour.rgb *= CorrectedLightColour(fragIn);

    // specular highlights, using blinn phong
    float3 specularLight = SpecularLight(fragIn.vertexNormal, fragIn.viewDirection, colour);
    colour.rgb = lerp(colour.rgb, specularLight, materialFeatureMask.g);

    #ifdef UNITY_PASS_FORWARDBASE
        // reflection using red channel
        float3 reflectionValue = GetReflection(fragIn);
        reflectionValue = lerp(colour.rgb, reflectionValue, _Reflectiveness);
        colour.rgb = lerp(colour.rgb, reflectionValue, materialFeatureMask.r);

        // glowwy
        float4 glowColour = float4(0, 0, 0, 0);
        if(_EnableGlow)
        {
            glowColour = tex2D(_GlowTexture, fragIn.uv);
            float glowHueShift = lerp(0, (_Time.y / _GlowSpeed), _EnableGlowColourChange);
            glowColour = ApplyHSVChangesToRGB(glowColour, float3(glowHueShift, 0, _GlowIntensity));
        }
        colour = lerp(colour, glowColour, glowColour.a);

        // wireframe
        if(_EnableWireframe == 1 && specialEffectsFeatureMask.g > 0.0f)
        {
            #ifdef _TRANSPARENT
                float4 wireframeColour = ApplyWireframeColour(colour, fragIn, specialEffectsFeatureMask.g);
                colour = lerp(wireframeColour, wireframeColour * colour.a, _MainColourAlphaAffectsWireframe);
            #else
                colour = ApplyWireframeColour(colour, fragIn, specialEffectsFeatureMask.g);
            #endif
        }

        // "psychedelic effect" of sorts, I guess
        // for now just a colour change over time based on normal direction, nothing fancy
        // but it looks neat
        if(_EnablePsychedelicEffect)
        {
            float4 psychedelicColour = float4(sin(normalize(fragIn.worldNormal).xyz * _PsychedelicWaveSize), 1) * 0.5 + 0.5;
            psychedelicColour = ApplyHSVChangesToRGB(psychedelicColour, float3(_Time.y / _PsychedelicSpeed, 0, 0));
            colour = lerp(colour, psychedelicColour, specialEffectsFeatureMask.b);
        }

        // colour inversion
    #endif

    colour *= _OverallBrightness;
    
    return colour;
}