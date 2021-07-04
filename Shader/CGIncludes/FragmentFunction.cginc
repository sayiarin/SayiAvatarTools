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


    float3 specialEffectsFeatureMask = tex2D(_SpecialFeatureMask, fragIn.uv);
    
    // hsv stuff, using red channel of feature mask
    float4 rgbNew = ApplyHSVChangesToRGB(colour, float3(_HueShift, _SaturationValue - 1, _ColourValue - 1));
    colour = lerp(colour, rgbNew, specialEffectsFeatureMask.r);

    // apply lighting
    colour.rgb *= CorrectedLightColour(fragIn);


    #ifndef UNITY_PASS_FORWARDADD
        float3 materialFeatureMask = tex2D(_MaterialFeatureMask, fragIn.uv);

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
        // _EnableWireframe is declared in the GeometryFunction.cginc because I use it there too
        // also take materialFeatureMask green channel into account for wireframe alpha
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
    #endif

    colour *= _OverallBrightness;

    return colour;
}