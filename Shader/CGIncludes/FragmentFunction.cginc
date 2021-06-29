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

    colour *= _OverallBrightness;
    // hsv stuff
    float hsvMask = tex2D(_HSVMask, fragIn.uv);
    float4 rgbNew = ApplyHSVChangesToRGB(colour, float3(_HueShift, _SaturationValue - 1, _ColourValue - 1));
    colour = lerp(colour, rgbNew, hsvMask);

    // apply lighting
    colour.rgb = ApplyLighting(fragIn, colour);


    #ifndef UNITY_PASS_FORWARDADD
        // reflection using red channel
        float4 reflectionMap = tex2D(_ReflectionMap, fragIn.uv);
        float3 reflectionValue = GetReflection(fragIn);
        reflectionValue = lerp(colour.rgb, reflectionValue, _Reflectiveness);
        colour.rgb = lerp(colour.rgb, reflectionValue, reflectionMap.r);
                
        // wireframe
        // _EnableWireframe is declared in the GeometryFunction.cginc because I use it there too
        if(_EnableWireframe == 1)
        {
            #ifdef _TRANSPARENT
                float4 wireframeColour = ApplyWireframeColour(colour, fragIn, fragIn.worldNormal);
                colour = lerp(wireframeColour, wireframeColour * colour.a, _MainColourAlphaAffectsWireframe);
            #else
                colour = ApplyWireframeColour(colour, fragIn, fragIn.worldNormal);
            #endif
        }

        // glowwy
        float4 glowColour = float4(0, 0, 0, 0);
        if(_EnableGlow)
        {
            glowColour = tex2D(_GlowTexture, fragIn.uv);
            float glowHueShift = lerp(0, (_Time.y / _GlowSpeed), _EnableGlowColourChange);
            glowColour = ApplyHSVChangesToRGB(glowColour, float3(glowHueShift, 0, _GlowIntensity));
        }
        colour = lerp(colour, glowColour, glowColour.a);
    #endif

    return colour;
}