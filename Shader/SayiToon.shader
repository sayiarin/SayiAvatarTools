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
        [Space]
        [Header(Special Effects)]
        [Toggle]_EnableOutline("Enable Outline", int) = 0
        _OutlineWidth("Outline Width", Range(0, 0.01)) = 0
        [HDR]_OutlineColour("Outline Colour", Color) = (0, 0, 0, 0)
        [Space]
        [Toggle]_EnableWireframe("Enable Wireframe", int) = 0
        _WireframeWidth("Wireframe Width", Range(0, 10)) = 2
        [HDR]_WireframeColour("Wireframe Colour", Color) = (1, 1, 1, 1)
        _WireframeFadeOutDistance("Wireframe Fade Out Distance", Range(0, 10)) = 1
        [Space]
        _HueShift("HueShift", Range(0, 1)) = 0
        _SaturationValue("Saturation", Range(0, 20)) = 1
        _ColourValue("Value", Range(0, 20)) = 1
        _HSVMask("HSV Mask", 2D) = "white" {}
        [Space]
        [Toggle]_EnableGlow("Enable Glow", int) = 0
        _GlowTexture("Glow Texture", 2D) = "black" {}
        _GlowIntensity("Glow Intensity", Range(1, 100)) = 10
        _GlowSpeed("Glow Colour Change Speed", Range(0.1, 60)) = 1
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
            
            Cull Off
            ZWrite On

            CGPROGRAM
            #pragma vertex VertexFunction
            #pragma geometry GeometryFunction
            #pragma fragment Fragment
            #pragma multi_compile_fwdbase

            #define _NEEDS_LIGHTING_DATA
            #define _USES_GEOMETRY
            #define _NEEDS_VERTEX_NORMAL
            #define _RECEIVES_SHADOWS
            #define _NEEDS_WORLD_POSITION

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"

            #include "CGIncludes/VertexFunction.cginc"
            #include "CGIncludes/GeometryFunction.cginc"
            #include "CGIncludes/ColourUtilities.cginc"
            #include "CGIncludes/Wireframe.cginc"

            // texture variables
            uniform UNITY_DECLARE_TEX2DARRAY(_BaseTextures);
            uniform int _TextureIndex;
            
            // lighting and shadows
            uniform float _ShadowSmoothness;
            uniform float _ShadowStrength;

            // hsv
            uniform float _HueShift;
            uniform float _SaturationValue;
            uniform float _ColourValue;
            uniform sampler2D _HSVMask;

            // glow
            uniform int _EnableGlow;
            uniform sampler2D _GlowTexture;
            uniform float _GlowIntensity;
            uniform float _GlowSpeed;

            float4 Fragment (Interpolators fragIn) : SV_TARGET
            {
                // get currently active texture from array as colour that will be output at the end
                float4 colour = UNITY_SAMPLE_TEX2DARRAY(_BaseTextures, float3(fragIn.uv, _TextureIndex));
                float3 worldNormal = normalize(fragIn.worldNormal);

                // check for glow effect first because if there's any I will just ignore any light input
                float4 glowColour = tex2D(_GlowTexture, fragIn.uv);
                if(_EnableGlow && glowColour.a > 0)
                {
                    colour = ApplyHSVChangesToRGB(colour, float3(_Time.y / _GlowSpeed, 0, _GlowIntensity));
                }
                else
                {
                    // shadow wooo
                    float diffuseLight = saturate(dot(_WorldSpaceLightPos0, worldNormal));

                    float lightAttenuation = LIGHT_ATTENUATION(fragIn);
                    float lightIntensity = smoothstep(0, _ShadowSmoothness, diffuseLight * lightAttenuation);
                    lightIntensity += (1 - _ShadowStrength);
                    lightIntensity = saturate(lightIntensity);
                    // work around to not be as bright until I learn read up on proper lighting/ambient light lol
                    colour *= lightIntensity / 2;

                    // add light probes
                    float3 lightProbe = ShadeSH9(float4(worldNormal, 1));
                    lightProbe *= lightIntensity;
                    colour.xyz += colour * lightProbe;

                    // apply direction light
                    float3  directLightColour = _LightColor0.rgb;
                    directLightColour *= lightIntensity;
                    directLightColour *= colour.rgb;
                    colour.xyz += colour.xyz * directLightColour;

                    // hsv stuff
                    float hsvMask = tex2D(_HSVMask, fragIn.uv);
                    float4 rgbNew = ApplyHSVChangesToRGB(colour, float3(_HueShift, _SaturationValue - 1, _ColourValue - 1));
                    colour = lerp(colour, rgbNew, hsvMask);
                }
                
                // wireframe
                // _EnableWireframe is declared in the GeometryFunction.cginc because I use it there too
                if(_EnableWireframe == 1)
                {
                    colour = ApplyWireframeColour(colour, fragIn, worldNormal);
                }

                return colour;
            }
            ENDCG
        }

        Pass
        {
            Tags { "RenderType" = "Opaque" }
            Name "Sayi Toon Outline"
        
            LOD 200
            Cull Front
            ZWrite On
        
            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "CGIncludes/Outline.cginc"
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ShadowCaster" }
            Name "Sayi Toon ShadowCaster"

            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct Interpolators
            {
                V2F_SHADOW_CASTER;
            };

            Interpolators Vertex(appdata_base v)
            {
                Interpolators output;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(output)
                return output;
            }

            float4 Fragment(Interpolators fragIn) : SV_TARGET
            {
                SHADOW_CASTER_FRAGMENT(fragIn);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
