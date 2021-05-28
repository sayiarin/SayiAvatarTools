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
        _HueShift("HueShift", Range(-1, 1)) = 0
        _SaturationValue("Saturation", Range(0, 20)) = 1
        _ColourValue("Value", Range(0, 20)) = 1
        _HSVMask("HSV Mask", 2D) = "white" {}
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

            float4 Fragment (Interpolators fragIn) : SV_TARGET
            {
                // get currently active texture from array as colour that will be output at the end
                float4 colour = UNITY_SAMPLE_TEX2DARRAY(_BaseTextures, float3(fragIn.uv, _TextureIndex));

                // shadow wooo
                float3 worldNormal = normalize(fragIn.worldNormal);
                float diffuseLight = saturate(dot(_WorldSpaceLightPos0, worldNormal));
                
                float lightAttenuation = LIGHT_ATTENUATION(fragIn);
                float lightIntensity = smoothstep(0, _ShadowSmoothness, diffuseLight * lightAttenuation);
                lightIntensity += (1 - _ShadowStrength);
                lightIntensity = saturate(lightIntensity);
                colour *= lightIntensity;

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
                float4 rgbNew = ApplyHSVChangesToRGB(colour, float3(_HueShift, _SaturationValue, _ColourValue));
                colour = lerp(colour, rgbNew, hsvMask);
                
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
