Shader "Sayiarin/SayiToon"
{
    Properties
    {
        [Space]
        // we will keep this stuff around so we can make the fallback diffuse shader look 
        // decent enough for people that don't have the shader shown
        [Header(Settings for the Fallback shader)]
        _MainTex("Fallback Texture", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0, 1)) = 0 
        _Metallic("Metallic", Range(0, 1)) = 0.0
        [Space]
        [Header(Texture Settings)]
        _BaseTextures("Base Textures", 2DArray) = "" {}
        _TextureIndex("Index of texture to use", int) = 0
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
        _MaterialFeatureMask("Material Feauture Mask", 2D) = "white" {}
        // purposefully choosing variable names different from default as to not make fallback look awkward
        _Smoothness("Smoothness", Range(0, 1)) = 0
        _Reflectiveness("Reflectiveness", Range(0, 1)) = 0
        [Toggle]_ReflectionIgnoresAlpha("Allow Reflections on Transparent Surface", int) = 0
        _SpecularHighlightExponent("Specular Highlight Exponent", Range(0.001, 2)) = .5
        [Space]
        [Toggle]_EnableWorldPosTexture("Enable World Position Texture", int) = 0
        _WorldPosTexture("World Position Texture", 2D) = "black" {}
        _WorldPosTextureZoom("World Position Texture Zoom level", Range(0.01, 2)) = 1
        [Space]
        [Header(Special Effects)]
        _SpecialFeatureMask("Special Effects Feature Mask", 2D) = "white" {}
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
        [Space]
        [Header(Glow)]
        [Toggle]_EnableGlow("Enable Glow", int) = 0
        _GlowTexture("Glow Texture", 2D) = "black" {}
        _GlowIntensity("Glow Intensity", Range(1, 100)) = 10
        [Toggle]_EnableGlowColourChange("Enable Colour Change Over Time", int) = 0
        _GlowSpeed("Glow Colour Change Speed", Range(0.01, 60)) = 1
        [Space]
        [Header(Rainbow Effect)]
        [Toggle]_EnableRainbowEffect("Enable Rainbow Effect", int) = 0
        _RainbowSpeed("Colour Change Speed", Range(0.01, 60)) = 5
        _RainbowWaveSize("Wave Size", Range(0.01, 100)) = 10
        [Space]
        [Toggle]_InvertColours("Invert Colours", int) = 0
        [Space]
        [Enum(Off, 0, Front, 1, Back, 2)] _CullMode("Culling Mode", int) = 2
        [Toggle] _ZWrite ("ZWrite", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("SrcBlend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("DstBlend", Float) = 0
    }
    CustomEditor "SayiToonShaderEditor"

    SubShader
    {
        LOD 200

        Tags { "RenderType" = "Opaque" }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            Name "SayiToonBase"
            
            Cull[_CullMode]
            ZWrite [_ZWrite]
            Blend [_SrcBlend] [_DstBlend]
        
            CGPROGRAM
            #pragma vertex VertexFunction
            #pragma geometry GeometryFunction
            #pragma fragment FragmentFunction
            
            #pragma multi_compile_fwdbase
            #pragma multi_compile_local __ SAYI_LIT
            #pragma multi_compile_local __ SAYI_TRANSPARENT
            
            #define _NEEDS_WORLD_NORMAL
            #define _NEEDS_LIGHTING_DATA
            #define _USES_GEOMETRY
            #define _NEEDS_VERTEX_NORMAL
            #define _NEEDS_VIEW_DIRECTION
            #define _RECEIVES_SHADOWS
            #define _NEEDS_WORLD_POSITION
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"
            
            #include "../CGIncludes/Properties.cginc"
            
            #include "../CGIncludes/VertexFunction.cginc"
            #include "../CGIncludes/GeometryFunction.cginc"
            #include "../CGIncludes/FragmentFunction.cginc"
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Name "SayiToonForwardAdd"

            Cull[_CullMode]
            ZWrite Off
            Blend One One

            CGPROGRAM

            #pragma vertex VertexFunction
            #pragma fragment FragmentFunction

            #pragma multi_compile_local __ SAYI_LIT
            
            #include "UnityCG.cginc"
            
            #if SAYI_LIT
                #pragma multi_compile_fwdadd_fullshadows

                #define _NEEDS_WORLD_NORMAL
                #define _NEEDS_VERTEX_NORMAL
                #define _NEEDS_WORLD_POSITION
                #define _NEEDS_VIEW_DIRECTION

                #include "Lighting.cginc"
                #include "UnityLightingCommon.cginc"
                #include "AutoLight.cginc"

                #include "../CGIncludes/Properties.cginc"

                #include "../CGIncludes/VertexFunction.cginc"
                #include "../CGIncludes/FragmentFunction.cginc"
            #else
                #include "../CGIncludes/DiscardPass.cginc"
            #endif
            ENDCG
        }

        Pass
        {
            Name "SayiToonOutline"

            LOD 200
            Cull Front
            ZWrite On

            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "../CGIncludes/Outline.cginc"
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ShadowCaster" }
            Name "SayiToonShadowCaster"

            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            #include "../CGIncludes/ShadowCaster.cginc"
            ENDCG
        }
    }
    FallBack "Diffuse"
}
