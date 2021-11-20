using UnityEngine;
using UnityEditor;

namespace SayiTools
{
    [CustomEditor(typeof(TextureArrayManager))]
    public class TextureArrayManagerEditor : Editor
    {
        private const string textureArrayAssetNamePrefix = "2DArray";
        private const string textureArrayInfoMessage = "The here referenced Texture2DArray will be overwriten with the new values once you press \"Generate Texture2DArray\".\n" +
            "If none is set this tool will create one for you here with the name {0}.";
        private const string texturesInvalidErrorMessage = "The textures selected are not valid for Texture2DArray creation!\n" +
            "Please make sure all the Textures selected share the same width, height and format.";
        private const string unableToGenerateTextureArrayErrorMessage = "TextureArrayManagerEditor {0}:\nThe textures selected are not valid, please see the info on the inspector window for Details!";

        SerializedProperty serializedTexture2DArray;
        SerializedProperty serializedTexture2D;

        private void OnEnable()
        {
            serializedTexture2DArray = serializedObject.FindProperty("textureArray");
            serializedTexture2D = serializedObject.FindProperty("textures");
        }

        public override void OnInspectorGUI()
        {
            EditorGUILayout.BeginVertical();
            EditorGUIHelper.HeaderLevel1("Texture Array Manager");

            EditorGUILayout.PropertyField(serializedTexture2D, includeChildren: true);
            EditorGUIHelper.Separator();

            EditorGUILayout.PropertyField(serializedTexture2DArray);
            EditorGUILayout.HelpBox(string.Format(textureArrayInfoMessage, GetTexture2DArrayAssetName()), MessageType.Info);
            EditorGUILayout.EndVertical();
            GUILayout.Space(EditorGUIUtility.singleLineHeight);

            // was trying to find a proper callback for saving when changes occur but just moved it
            // here for now because of simplicity until I find something better
            serializedObject.ApplyModifiedProperties();

            // we get the values that we need directly from the object itself because getting the
            // values from the serialised properties
            TextureArrayManager textureArrayManager = serializedObject.targetObject as TextureArrayManager;
            bool texturesAreValid = TextureHelper.TexturesShareDimensionsAndFormat(textureArrayManager.textures);

            if (!texturesAreValid)
            {
                EditorGUILayout.HelpBox(texturesInvalidErrorMessage, MessageType.Error);
            }

            EditorGUI.BeginDisabledGroup(!texturesAreValid);
            if (GUILayout.Button("Generate Texture2DArray"))
            {
                if (!texturesAreValid)
                {
                    Debug.LogError(string.Format(unableToGenerateTextureArrayErrorMessage, AssetDatabase.GetAssetPath(serializedObject.targetObject)));
                    return;
                }

                EditorUtility.DisplayProgressBar(EditorGUIHelper.ProgressTitle, "Creating tex2d array ...", 0f);
                Texture2DArray newTexture2DArray = CreateTexture2DArray(textureArrayManager.textures);
                // overwrite if exists, otherwise create
                if (textureArrayManager.textureArray)
                {
                    EditorUtility.DisplayProgressBar(EditorGUIHelper.ProgressTitle, "Saving assets ...", .5f);
                    Texture2DArray existingTexture2DArray = AssetDatabase.LoadAssetAtPath<Texture2DArray>(AssetDatabase.GetAssetPath(textureArrayManager.textureArray));
                    EditorUtility.CopySerialized(newTexture2DArray, existingTexture2DArray);
                    AssetDatabase.SaveAssets();
                }
                else
                {
                    EditorUtility.DisplayProgressBar(EditorGUIHelper.ProgressTitle, "Saving assets ...", .5f);
                    string assetPath = AssetDatabase.GetAssetPath(target);
                    assetPath = assetPath.Remove(assetPath.LastIndexOf('/'));
                    assetPath = string.Format("{0}/{1}.asset", assetPath, GetTexture2DArrayAssetName());
                    AssetDatabase.CreateAsset(newTexture2DArray, assetPath);
                    AssetDatabase.SaveAssets();

                    EditorUtility.DisplayProgressBar(EditorGUIHelper.ProgressTitle, "Updating Database ...", .9f);
                    // after saving assign the new asset to this editor, update and save just in case
                    textureArrayManager.textureArray = newTexture2DArray;
                    serializedObject.Update();
                    serializedObject.ApplyModifiedProperties();

                }
                EditorUtility.DisplayProgressBar(EditorGUIHelper.ProgressTitle, "Completed!", 1f);
                EditorUtility.ClearProgressBar();
            }
            EditorGUI.EndDisabledGroup();
        }

        private string GetTexture2DArrayAssetName()
        {
            return string.Format("{0}_{1}", textureArrayAssetNamePrefix, target.name);
        }

        public static Texture2DArray CreateTexture2DArray(Texture2D[] textures)
        {
            Texture2DArray textureArray = new Texture2DArray(textures[0].width, textures[0].height, textures.Length, textures[0].format, true);
            for (int i = 0; i < textures.Length; i++)
            {
                for (int mipMap = 0; mipMap < textures[i].mipmapCount; mipMap++)
                {
                    Graphics.CopyTexture(textures[i], 0, mipMap, textureArray, i, mipMap);
                }
            }
            return textureArray;
        }
    }
}
