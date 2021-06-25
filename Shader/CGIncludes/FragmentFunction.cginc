#include "ColourUtilities.cginc"
#include "Wireframe.cginc"
#include "Reflection.cginc"

// texture variables
#ifdef _SIMPLE
uniform sampler2D _MainTex;
#else
uniform UNITY_DECLARE_TEX2DARRAY(_BaseTextures);
uniform int _TextureIndex;
#endif

uniform float _OverallBrightness;

// directional lighting and shadows
#ifdef _LIT
uniform float _ShadowSmoothness;
uniform float _ShadowStrength;
uniform int _EnableShadowRamp;
uniform sampler2D _ShadowRamp;
#endif

// fake lighting and shadows, only on unlit version
#ifndef _LIT
uniform int _EnableFakeShadows;
uniform float _FakeShadowStrength;
uniform float4 _FakeLightDirection;
uniform sampler2D _FakeShadowRamp;
#endif

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

    // only relevant for lit shader, unlit ignores world lighting
    #ifdef _LIT
    // shadow wooo

    if(_EnableShadowRamp)
    {
        float lightDirection = saturate(dot(worldNormal, normalize(_WorldSpaceLightPos0)) + 1) / 2;
        float4 shadowColour = tex2D(_ShadowRamp, float2(lightDirection, 0));
        colour *= saturate(shadowColour + (1 - _ShadowStrength));
    }
    else
    {
        float lightDirection = saturate(dot(worldNormal, normalize(_WorldSpaceLightPos0)));
        float lightAttenuation = LIGHT_ATTENUATION(fragIn) / SHADOW_ATTENUATION(fragIn);
        float lightIntensity = smoothstep(0, _ShadowSmoothness, lightDirection * lightAttenuation);

        // properly not the best way but it works, so mh
        lightIntensity += (1 - _ShadowStrength);
        colour *= lightIntensity / 2;
    }

    // apply direction light
    float3  directLightColour = _LightColor0.rgb;
    colour.xyz *= directLightColour;
    #endif

    // only unlit has fake shadows
    #ifndef _LIT
    if(_EnableFakeShadows)
    {
        float shadowRampPosition = (dot(fragIn.worldNormal, normalize(_FakeLightDirection)) + 1) / 2;
        float4 fakeShadowColour = tex2D(_FakeShadowRamp, float2(shadowRampPosition, 0));
        colour *= saturate(fakeShadowColour + (1 - _FakeShadowStrength));
    }
    #endif
                   
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