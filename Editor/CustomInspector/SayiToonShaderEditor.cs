#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;
using System;

// sadly the Editor GUI only works if is in the default namespace :<
public class SayiToonShaderEditor : ShaderGUI
{
    private const string FallbackInfo = "These settings are for the Unity Standard Shader to control how your avatar looks to people that don't have your shader shown.";
    private const string MaterialSettingsInfoText = @"The Material Feature mask will maps features to parts of your texture using the different colour channels to distinguish between them.
For ease of use make sure you use the Texture Combiner(Tools > Sayi > ImageCombiner) to create the final mask, using black white as the basis for each colour channel will yield the best result.
The setup is as follows:
R - reflection/smoothness
G - specular highlights";
    private const string SpecialEffectsInfoText = @"The Special Feature Mask maps special effects to parts of your texture using the different colour channels to distinguish between them.
For ease of use make sure you use the Texture Combiner(Tools > Sayi > ImageCombiner) to create the final mask, using black white as the basis for each colour channel will yield the best result.
The setup is as follows:
R - Hue/Saturation/Value Changes
G - Wireframe
B - Rainbow Effect
A - Colour Inversion";
    private const string GlowInfoMessage = "For the glow provide a texture. The glow will appear in the colour of any part, transparent values will mean the base texture is rendered instead.";

    private MaterialEditor MatEditor;
    private MaterialProperty[] Properties;
    private Material Mat;

    private bool AlphaAsTransparent = false;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        MatEditor = materialEditor;
        Properties = properties;
        Mat = materialEditor.target as Material;

        SayiTools.EditorGUIHelper.HeaderLevel1("Sayi Toon");

        DrawFoldoutWithOptions("Fallback Settings", FallbackInfo, "ShowFallbackSettings", FallbackSettings);
        DrawFoldoutWithOptions("General Settings", "ShowGeneralSettings", GeneralSettings);
        DrawFoldoutWithOptions("Material Settings", "ShowMaterialSettings", MaterialSettings);
        DrawFoldoutWithOptions("Special Effects", "ShowSpecialEffectsSettings", SpecialEffects);
    }

    private void FallbackSettings()
    {
        TextureProperty("_MainTex", "Fallback Texture");
        RangeProperty("_Glossiness", "Smoothness");
        RangeProperty("_Metallic", "Metallic");
    }

    private void GeneralSettings()
    {
        MaterialProperty cullMode = FindProperty("_CullMode", Properties);
        MatEditor.ShaderProperty(cullMode, "Cull Mode");

        EditorGUI.BeginChangeCheck();
        AlphaAsTransparent = EditorGUILayout.Toggle("Alpha as Transparency", AlphaAsTransparent);
        if (EditorGUI.EndChangeCheck())
        {
            if (AlphaAsTransparent)
            {
                Mat.SetOverrideTag("RenderType", "Transparent");
                Mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                Mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                Mat.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                Mat.EnableKeyword("SAYI_TRANSPARENT");
            }
            else
            {
                Mat.SetOverrideTag("RenderType", "Opaque");
                Mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                Mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                Mat.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Geometry;
                Mat.DisableKeyword("SAYI_TRANSPARENT");
            }
        }
        MatEditor.RenderQueueField();
        bool litState = ToggleKeyword("SAYI_LIT", "Affected by Environment Lighting");
        Mat.SetShaderPassEnabled("SayiToonForwardAdd", litState);

        EditorGUILayout.Space(EditorGUIUtility.singleLineHeight);

        TextureProperty("_BaseTextures", "Texture Array");
        FloatProperty("_TextureIndex", "Texture Index");
        RangeProperty("_OverallBrightness", "Base Brightness");

        EditorGUILayout.Space(EditorGUIUtility.singleLineHeight);

        DrawFoldoutWithOptions("Shadows", "ShowShadowSettings", ShadowSettings);
    }

    private void ShadowSettings()
    {
        bool shadow = ToggleProperty("_EnableDirectionalShadow", "Enable Directional Shadows");
        EditorGUI.BeginDisabledGroup(!shadow);
        RangeProperty("_ShadowStrength", "Shadow Strength");
        RangeProperty("_ShadowSmoothness", "Shadow Smoothness");

        bool shadowRamp = ToggleProperty("_EnableShadowRamp", "Enable Shadow Ramp");
        EditorGUI.BeginDisabledGroup(!shadowRamp);
        TextureProperty("_ShadowRamp", "Shadow Ramp Texture");
        EditorGUI.EndDisabledGroup();
        EditorGUI.EndDisabledGroup();
    }

    private void MaterialSettings()
    {
        EditorGUILayout.HelpBox(MaterialSettingsInfoText, MessageType.Info);
        TextureProperty("_MaterialFeatureMask", "Material Feature Mask");
        RangeProperty("_Smoothness", "Smoothness");
        RangeProperty("_Reflectiveness", "Reflectiveness");
        RangeProperty("_SpecularHighlightExponent", "Specular Highlight Exponent");
    }

    private void SpecialEffects()
    {
        EditorGUILayout.HelpBox(SpecialEffectsInfoText, MessageType.Info);
        TextureProperty("_SpecialFeatureMask", "Special Feature Mask");

        EditorGUILayout.Space(EditorGUIUtility.singleLineHeight);

        RangeProperty("_HueShift", "Hue");
        RangeProperty("_SaturationValue", "Saturation");
        RangeProperty("_ColourValue", "Value");

        EditorGUILayout.Space(EditorGUIUtility.singleLineHeight);

        bool outline = ToggleProperty("_EnableOutline", "Enable Outline");
        EditorGUI.BeginDisabledGroup(!outline);
        RangeProperty("_OutlineWidth", "Width");
        ColourProperty("_OutlineColour", "Colour");
        EditorGUI.EndDisabledGroup();

        EditorGUILayout.Space(EditorGUIUtility.singleLineHeight);

        bool wireframe = ToggleProperty("_EnableWireframe", "Wireframe");
        EditorGUI.BeginDisabledGroup(!wireframe);
        RangeProperty("_WireframeWidth", "Width");
        ColourProperty("_WireframeColour", "Colour");
        RangeProperty("_WireframeFadeOutDistance", "Fadeout Distance");
        EditorGUI.EndDisabledGroup();

        EditorGUILayout.Space(EditorGUIUtility.singleLineHeight);

        bool rainbow = ToggleProperty("_EnableRainbowEffect", "Enable Rainbow Effect");
        EditorGUI.BeginDisabledGroup(!rainbow);
        RangeProperty("_RainbowSpeed", "Speed");
        RangeProperty("_RainbowWaveSize", "Wave Size");
        EditorGUI.EndDisabledGroup();

        EditorGUILayout.Space(EditorGUIUtility.singleLineHeight);

        bool worldPosTex = ToggleProperty("_EnableWorldPosTexture", "World Position Texture");
        EditorGUI.BeginDisabledGroup(!worldPosTex);
        TextureProperty("_WorldPosTexture", "Texture");
        RangeProperty("_WorldPosTextureZoom", "Zoom");
        EditorGUI.EndDisabledGroup();

        EditorGUILayout.Space(EditorGUIUtility.singleLineHeight);

        ToggleProperty("_InvertColours", "Invert Colours");

        EditorGUILayout.Space(EditorGUIUtility.singleLineHeight);

        DrawFoldoutWithOptions("Glow Effect", "ShowGlowEffect", GlowEffect);
    }

    private void GlowEffect()
    {
        bool glow = ToggleProperty("_EnableGlow", "Enable Glow Effect");
        EditorGUI.BeginDisabledGroup(!glow);
        if (glow)
        {
            EditorGUILayout.HelpBox(GlowInfoMessage, MessageType.Info);
        }
        TextureProperty("_GlowTexture", "Glow Texture");
        RangeProperty("_GlowIntensity", "Glow Intensity");
        bool glowChange = ToggleProperty("_EnableGlowColourChange", "enable Glow Colour Change over Time");
        EditorGUI.BeginDisabledGroup(!glowChange);
        RangeProperty("_GlowSpeed", "Colour Change Speed");
        EditorGUI.EndDisabledGroup();
        EditorGUI.EndDisabledGroup();
    }

    private void DrawFoldoutWithOptions(string title, string toggleKey, Action optionFunc)
    {
        DrawFoldoutWithOptions(title, "", toggleKey, optionFunc);
    }

    private void DrawFoldoutWithOptions(string title, string infoMessage, string toggleKey, Action optionFunc)
    {
        // just to be safe prefix all keys with SayiToon
        toggleKey = "SayiToon" + toggleKey;

        bool prevState = EditorPrefs.GetBool(toggleKey, false);
        bool state = EditorGUILayout.Foldout(prevState, title, SayiTools.EditorGUIHelper.GetFoldoutStyle());

        if (prevState != state)
        {
            EditorPrefs.SetBool(toggleKey, state);
        }

        if (state)
        {
            if (!String.IsNullOrWhiteSpace(infoMessage))
            {
                EditorGUILayout.HelpBox(infoMessage, MessageType.Info);
            }

            SayiTools.EditorGUIHelper.BeginBox();
            optionFunc();
            SayiTools.EditorGUIHelper.EndBox();
        }
    }

    // just some helper functions for common property types
    private void FloatProperty(string propertyName, string label)
    {
        MaterialProperty prop = FindProperty(propertyName, Properties);
        MatEditor.FloatProperty(prop, label);
    }

    private void RangeProperty(string propertyName, string label)
    {
        MaterialProperty prop = FindProperty(propertyName, Properties);
        MatEditor.RangeProperty(prop, label);
    }

    private void TextureProperty(string propertyName, string label)
    {
        MaterialProperty prop = FindProperty(propertyName, Properties);
        MatEditor.TextureProperty(prop, label);
    }

    private void ColourProperty(string propertyName, string label)
    {
        MaterialProperty prop = FindProperty(propertyName, Properties);
        MatEditor.ColorProperty(prop, label);
    }

    private bool ToggleProperty(string propertyName, string label)
    {
        MaterialProperty prop = FindProperty(propertyName, Properties);
        bool state = prop.floatValue != 0.0f;

        state = EditorGUILayout.Toggle(label, state);
        prop.floatValue = state ? 1.0f : 0.0f;

        return state;
    }

    private bool ToggleKeyword(string keyword, string label)
    {
        bool state = Mat.IsKeywordEnabled(keyword);
        state = EditorGUILayout.Toggle(label, state);
        if (state)
        {
            Mat.EnableKeyword(keyword);
        }
        else
        {
            Mat.DisableKeyword(keyword);
        }

        return state;
    }
}
#endif