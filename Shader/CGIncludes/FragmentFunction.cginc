#include "ColourUtilities.cginc"
#include "Wireframe.cginc"
#include "Reflection.cginc"

// texture variables
uniform UNITY_DECLARE_TEX2DARRAY(_BaseTextures);
uniform int _TextureIndex;

uniform float _OverallBrightness;

#ifdef _LIT
// lighting and shadows
uniform float _ShadowSmoothness;
uniform float _ShadowStrength;
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


float4 Fragment (Interpolators fragIn) : SV_TARGET
{
    // get currently active texture from array as colour that will be output at the end
    float4 colour = UNITY_SAMPLE_TEX2DARRAY(_BaseTextures, float3(fragIn.uv, _TextureIndex));
    colour *= _OverallBrightness;

    float3 worldNormal = normalize(fragIn.worldNormal);

    // only relevant for lit shader, unlit ignores world lighting
    #ifdef _LIT
        // shadow wooo
        float diffuseLight = saturate(dot(_WorldSpaceLightPos0, worldNormal));

        float lightAttenuation = LIGHT_ATTENUATION(fragIn) / SHADOW_ATTENUATION(fragIn);
        float lightIntensity = smoothstep(0, _ShadowSmoothness, diffuseLight * lightAttenuation);
        // work around to not be as bright until I learn read up on proper lighting/ambient light lol
        lightIntensity += (1 - _ShadowStrength);
        colour *= lightIntensity / 2;

        // apply direction light
        float3  directLightColour = _LightColor0.rgb;
        colour.xyz *= directLightColour;
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
        colour = ApplyWireframeColour(colour, fragIn, worldNormal);
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