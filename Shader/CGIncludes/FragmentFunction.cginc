#include "ColourUtilities.cginc"
#include "Wireframe.cginc"
#include "Reflection.cginc"
#include "LightUtilities.cginc"

// texture variables
#ifdef _SIMPLE
uniform sampler2D _MainTex;
#else
uniform UNITY_DECLARE_TEX2DARRAY(_BaseTextures);
uniform int _TextureIndex;
#endif

uniform float _OverallBrightness;

// reflection
uniform sampler2D _ReflectionMap;
uniform float _Reflectiveness;

// hsv
uniform float _HueShift;
uniform float _SaturationValue;
uniform float _ColourValue;
uniform sampler2D _HSVMask;

// glow
uniform int _EnableGlow;
uniform int _EnableGlowColourChange;
uniform sampler2D _GlowTexture;
uniform float _GlowIntensity;
uniform float _GlowSpeed;

// wireframe - only relevant for transparent shader
#ifdef _TRANSPARENT
uniform int _MainColourAlphaAffectsWireframe;
#endif


float4 Fragment (Interpolators fragIn) : SV_TARGET
{
    float4 colour;
    #ifdef _SIMPLE
        colour = tex2D(_MainTex, fragIn.uv);
    #else
        // get currently active texture from array as colour that will be output at the end
        colour = UNITY_SAMPLE_TEX2DARRAY(_BaseTextures, float3(fragIn.uv, _TextureIndex));
    #endif

    colour *= _OverallBrightness;

    float3 worldNormal = normalize(fragIn.worldNormal);

    colour.rgb = ApplyLighting(fragIn, colour);

    // hsv stuff
    float hsvMask = tex2D(_HSVMask, fragIn.uv);
    float4 rgbNew = ApplyHSVChangesToRGB(colour, float3(_HueShift, _SaturationValue - 1, _ColourValue - 1));
    colour = lerp(colour, rgbNew, hsvMask);

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
            float4 wireframeColour = ApplyWireframeColour(colour, fragIn, worldNormal);
            colour = lerp(wireframeColour, wireframeColour * colour.a, _MainColourAlphaAffectsWireframe);
        #else
            colour = ApplyWireframeColour(colour, fragIn, worldNormal);
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

    return colour;
}