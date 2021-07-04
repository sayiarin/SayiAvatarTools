// (almost) all properties being used by the SayiToon shaders
// some properties may not appear here because it just makes more sense to have them 
// in their own cginc file where they are being used. A good example would be the
// Outline.cginc and it's respective properties since I basically put everything related
// to that into one include file

// toggle wireframe, also affects geometry function
#ifdef _USES_GEOMETRY
uniform int _EnableWireframe;
#endif

// texture variables
#ifdef _SIMPLE
uniform sampler2D _MainTex;
#else
uniform UNITY_DECLARE_TEX2DARRAY(_BaseTextures);
uniform int _TextureIndex;
#endif

uniform float _OverallBrightness;

// Material Features, Mask uses rgb channels for different settings
// r - reflection/smoothness
// g - specular highlights
// b - height map
uniform sampler2D _MaterialFeatureMask;
uniform float _Reflectiveness;
uniform float _Smoothness;
uniform float _SpecularHighlightStrength;

// special feature map, using rgb channels for different settings
// r - HSV changes
// g - Wireframe
// b - "psychadelic" Effect
uniform sampler2D _SpecialFeatureMask;

// hsv
uniform float _HueShift;
uniform float _SaturationValue;
uniform float _ColourValue;

// "psychadelic" Effect
uniform int _EnablePsychedelicEffect;
uniform float _PsychedelicSpeed;
uniform float _PsychedelicWaveSize;

// lighting variables
#ifdef _LIT
uniform int _EnableDirectionalShadow;
uniform float _ShadowSmoothness;
uniform float _ShadowStrength;
uniform int _EnableShadowRamp;
uniform sampler2D _ShadowRamp;

// fake lighting and shadows, only on unlit version
#else
uniform int _EnableFakeShadows;
uniform float _FakeShadowStrength;
uniform float4 _FakeLightDirection;
uniform sampler2D _FakeShadowRamp;
#endif

// glow
uniform int _EnableGlow;
uniform int _EnableGlowColourChange;
uniform sampler2D _GlowTexture;
uniform float _GlowIntensity;
uniform float _GlowSpeed;

// wireframe
uniform float4 _WireframeColour;
uniform float _WireframeWidth;
uniform float _WireframeFadeOutDistance;
#ifdef _TRANSPARENT
uniform int _MainColourAlphaAffectsWireframe;
#endif
