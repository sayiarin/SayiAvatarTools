Shader "Sayiarin/SayiToon Simple Lit - Transparent"
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
        _OverallBrightness("Overall Brightness", Range(0, 2)) = 1
        [Space]
        [Header(Lighting Settings)]
        [Toggle]_EnableDirectionalShadow("Enable Directional Light Shadows", int) = 0
        _ShadowStrength("Strength", Range(0, 1)) = 0.5
        _ShadowSmoothness("Smoothness", Range(0, 1)) = 0.05
        [Toggle]_EnableShadowRamp("Enable Shadow Ramp", int) = 0
        _ShadowRamp("Shadow Ramp", 2D) = "white" {}
        [Space]
        [Header(Reflections)]
        _ReflectionMap("Reflection Map", 2D) = "black" {}
        // purposefully choosing variable names different from default as to not make fallback look awkward
        _Smoothness("Smoothness", Range(0, 1)) = 0
        _Reflectiveness("Reflectiveness", Range(0, 1)) = 0
        [Space]
        [Header(Special Effects)]
        [Header(Outline)]
        [Toggle]_EnableOutline("Enable Outline", int) = 0
        _OutlineWidth("Outline Width", Range(0, 0.01)) = 0
        [HDR]_OutlineColour("Outline Colour", Color) = (0, 0, 0, 0)
        [Space]
        [Header(Wireframe)]
        [Toggle]_EnableWireframe("Enable Wireframe", int) = 0
        _WireframeWidth("Wireframe Width", Range(0, 10)) = 2
        [HDR]_WireframeColour("Wireframe Colour", Color) = (1, 1, 1, 1)
        _WireframeFadeOutDistance("Wireframe Fade Out Distance", Range(0, 10)) = 1
        [Space]
        [Header(HueShift)]
        _HueShift("HueShift", Range(0, 1)) = 0
        _SaturationValue("Saturation", Range(0, 20)) = 1
        _ColourValue("Value", Range(0, 20)) = 1
        _HSVMask("HSV Mask", 2D) = "white" {}
        [Space]
        [Header(Glow)]
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
                "RenderType" = "Transparent"
                "Queue" = "Transparent"
                "LightMode" = "ForwardBase"
                "PassFlags" = "OnlyDirectional"
            }
            Name "Sayi Toon Base"
            
            Cull Off
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex VertexFunction
            #pragma geometry GeometryFunction
            #pragma fragment Fragment
            #pragma multi_compile_fwdbase

            #define _NEEDS_WORLD_NORMAL
            #define _NEEDS_LIGHTING_DATA
            #define _USES_GEOMETRY
            #define _NEEDS_VERTEX_NORMAL
            #define _NEEDS_VIEW_DIRECTION
            #define _RECEIVES_SHADOWS
            #define _NEEDS_WORLD_POSITION

            #define _LIT
            #define _SIMPLE

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"

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
