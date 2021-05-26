Shader "Sayiarin/SayiToon"
{
    Properties
    {
        [Space]
        // we will keep this stuff around so we can make the fallback diffuse shader look 
        // decent enough for people that don't have the shader shown
        [Header(Settings for the Fallback shader)]
        _MainTex ("Fallback Texture", 2D) = "white" {}
        _Glossiness ("Smoothness", Float) = 0 
        _Metallic ("Metallic", Range(0, 1)) = 0.0
        [Space]
        [Header(Texture Settings)]
        _BaseTextures("Base Textures", 2DArray) = "" {}
        _TextureIndex("Index of texture to use", int) = 0
        [Space]
        [Header(Lighting Settings)]
        _ShadowStrength("Strength", Range(0, 1)) = 0.5
        _ShadowSmoothness("Smoothness", Range(0, 1)) = 0.05
        _ShadowRamp("Shadow Ramp", 2D) = "white" {}
        [Space]
        [Header(Special Effects)]
        _OutlineWidth("Outline Width", Range(0, 0.01)) = 0
        [HDR]_OutlineColour("Outline Colour", Color) = (0, 0, 0, 0)

    }

    SubShader
    {
        LOD 200

        Pass
        {
            Tags
            {
                "RenderType" = "Opaque"
                "LightMode" = "ForwardBase"
                "PassFlags" = "OnlyDirectional"
            }
            Name "Sayi Toon Base"

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
            uniform float _ShadowSmoothness;
            uniform float _ShadowStrength;

            float4 Fragment (VertexData fragIn) :SV_TARGET
            {
                // get currently active texture from array as colour that will be output at the end
                float4 colour = UNITY_SAMPLE_TEX2DARRAY(_BaseTextures, float3(fragIn.uv, _TextureIndex));

                // shadow wooo
                float3 normal = normalize(fragIn.worldNormal);
                float diffuseLight = saturate(dot(_WorldSpaceLightPos0, normal));

                float lightIntensity = smoothstep(0, _ShadowSmoothness, diffuseLight);
                lightIntensity += (1 - _ShadowStrength);


                lightIntensity = saturate(lightIntensity);
                colour *= lightIntensity * _LightColor0;

                return colour;
            }
            ENDCG
        }

        Pass
        {
            Tags { "RenderType" = "Opaque" }
            Name "Sayi Toon Outline"
        
            Cull Front
        
            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "CGIncludes/Outline.cginc"
            ENDCG
        }
    }
    FallBack "Diffuse"
}
