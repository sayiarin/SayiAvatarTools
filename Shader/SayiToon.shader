Shader "Sayiarin/SayiToon"
{
    Properties
    {
        [Space]
        // we will keep this stuff around so we can make the fallback diffuse shader look 
        // decent enough for people that don't have the shader shown
        [Header(Settings for the Fallback shader)]
        _MainTex ("Fallback Texture", 2D) = "white" {}
        _Glossiness ("Smoothness", Float) = 32
        _Metallic ("Metallic", Range(0, 1)) = 0.0
        [Space]
        [Header(Texture Settings)]
        _BaseTextures("Base Textures", 2DArray) = "" {}
        _TextureIndex("Index of texture to use", int) = 0
        [Space]
        [Header(Lighting Settings)]
        _ShadowStrength("Strength", Range(0, 1)) = 0.5
        _ShadowSmoothness("Smoothness", Range(0, 1)) = 0.05
        [Space]
        [HDR] _RimColour("Rim Colour", Color) = (1, 1, 1, 1)
        _RimAmount("Rim Amount", Range(0, 1)) = 0.5
        _RimThreshold("Rim Threshold", Range(0, 1)) = 0.1
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "LightMode" = "ForwardBase"
            "PassFlags" = "OnlyDirectional"
        }

        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexFunction
            #pragma fragment Fragment
            #pragma multi_compile_fwdbase

            #define _USES_LIGHTING

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "CGIncludes/VertexFunction.cginc"

            // texture variables
            uniform sampler2D _MainTex;
            uniform UNITY_DECLARE_TEX2DARRAY(_BaseTextures);
            uniform int _TextureIndex;

            // lighting variables
            uniform float _ShadowStrength;
            uniform float _ShadowSmoothness;
            uniform float4 _RimColour;
            uniform float _RimAmount;
            uniform float _RimThreshold;

            float4 Fragment (VertexData fragIn) :SV_TARGET
            {
                // get currently active texture from array as colour that will be output at the end
                float4 colour = UNITY_SAMPLE_TEX2DARRAY(_BaseTextures, float3(fragIn.uv, _TextureIndex));

                // shadow wooo - using Blinn-Phong
                float3 normal = normalize(fragIn.worldNormal);
                float NdotL = dot(_WorldSpaceLightPos0, normal);

                float shadow = SHADOW_ATTENUATION(fragIn);
                float lightIntensity = smoothstep(0, 0.01, NdotL * shadow);
                lightIntensity += (1-_ShadowStrength);
                float finalLightIntensity = lightIntensity * _LightColor0;

                // rim Lighting
                float3 viewDirection = normalize(fragIn.viewDirection);
                float rimIntensity = 1 - dot(viewDirection, normal);
                rimIntensity = rimIntensity * pow(NdotL, _RimThreshold);
                rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);

                float4 rim = rimIntensity * _RimColour;

                return colour * (finalLightIntensity + rim);
            }
            ENDCG
        }

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
    FallBack "Diffuse"
}
