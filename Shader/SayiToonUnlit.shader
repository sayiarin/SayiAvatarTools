Shader "Sayiarin/SayiToon Unlit"
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
        _OverallBrightness("Overall Brightness", Range(0, 2)) = 1
        [Space]
        [Header(Reflections)]
        _ReflectionMap("Reflection Map", 2D) = "black" {}
        // purposefully choosing variable names different from default as to not make fallback look awkward
        _Smoothness("Smoothness", Range(0, 1)) = 0
        _Reflectiveness("Reflectiveness", Range(0, 1)) = 0
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
        [Toggle]_EnableGlowColourChange("Enable Colour Change Over Time", int) = 0
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
            
            #define _USES_GEOMETRY
            #define _NEEDS_VERTEX_NORMAL
            #define _NEEDS_WORLD_POSITION
            #define _NEEDS_NORMAL
            #define _NEEDS_VIEW_DIRECTION

            #include "UnityCG.cginc"
            // need to include Lighting.ginc for reflection probes
            #include "Lighting.cginc"

            #include "CGIncludes/VertexFunction.cginc"
            #include "CGIncludes/GeometryFunction.cginc"
            #include "CGIncludes/FragmentFunction.cginc"
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

            #include "CGIncludes/ShadowCaster.cginc"
            ENDCG
        }
    }
    FallBack "Diffuse"
}
