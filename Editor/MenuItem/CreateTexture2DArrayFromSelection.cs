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
            bool selectionIsValid = TextureArrayManagerEditor.TexturesShareDimensionsAndFormat(textures);

            if (selectionIsValid == false)
            {
                Debug.LogError("Unable to create TextureArray; Please check all files have the same width, height and format.");
                return;
            }

            Texture2DArray textureArray = TextureArrayManagerEditor.CreateTexture2DArray(textures);
            string assetPath = AssetDatabase.GetAssetPath(textures[0]);
            assetPath = assetPath.Remove(assetPath.LastIndexOf('/')) + "/GeneratedTexture2DArray.asset";
            AssetDatabase.CreateAsset(textureArray, assetPath);
            AssetDatabase.SaveAssets();

            Debug.Log(String.Format("Texture Array successfully created at {0}!", assetPath));
            Selection.activeObject = textureArray;
        }

        [MenuItem("Assets/Sayi Tools/Create Texture Array From Selection", true)]
        private static bool Texture2DArrayCreatorValidation()
        {
            return Selection.GetFiltered<Texture2D>(SelectionMode.TopLevel).Length > 0;
        }
    }
}