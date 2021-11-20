using UnityEngine;
using UnityEditor;
using System;

namespace SayiTools
{
    public class CreateTexture2DArrayFromSelection : ScriptableObject
    {
        [MenuItem("Assets/Sayi Tools/Create Texture Array From Selection", false, 100)]
        private static void Texture2DArrayCreator()
        {
            Texture2D[] textures = Selection.GetFiltered<Texture2D>(SelectionMode.TopLevel);
            Array.Sort(textures, (UnityEngine.Object one, UnityEngine.Object two) => one.name.CompareTo(two.name));
            bool selectionIsValid = TextureHelper.TexturesShareDimensionsAndFormat(textures);

            if (selectionIsValid == false)
            {
                Debug.LogError("Unable to create TextureArray; Please check all files have the same width, height and format.");
                return;
            }

            EditorUtility.DisplayProgressBar(EditorGUIHelper.ProgressTitle, "Creating tex2d array ...", 0f);
            Texture2DArray textureArray = TextureArrayManagerEditor.CreateTexture2DArray(textures);
            EditorUtility.DisplayProgressBar(EditorGUIHelper.ProgressTitle, "Saving Assets ...", .5f);
            string assetPath = AssetDatabase.GetAssetPath(textures[0]);
            assetPath = assetPath.Remove(assetPath.LastIndexOf('/')) + "/GeneratedTexture2DArray.asset";
            AssetDatabase.CreateAsset(textureArray, assetPath);
            AssetDatabase.SaveAssets();

            EditorUtility.DisplayProgressBar(EditorGUIHelper.ProgressTitle, "Finished!", 1f);
            Debug.Log(String.Format("Texture Array successfully created at {0}!", assetPath));
            Selection.activeObject = textureArray;
            EditorUtility.ClearProgressBar();
        }

        [MenuItem("Assets/Sayi Tools/Create Texture Array From Selection", true)]
        private static bool Texture2DArrayCreatorValidation()
        {
            return Selection.GetFiltered<Texture2D>(SelectionMode.TopLevel).Length > 0;
        }
    }
}