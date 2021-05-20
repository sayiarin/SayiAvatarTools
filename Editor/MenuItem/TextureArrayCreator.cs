using UnityEngine;
using UnityEditor;
using System;

namespace SayiTools
{
    public class TextureArrayCreator : ScriptableObject
    {
        #region Create Asset Menu
        [MenuItem("Assets/Sayi Tools/Create Texture Array", false, 100)]
        private static void Texture2DArrayCreator()
        {
            Texture2D[] textures = Selection.GetFiltered<Texture2D>(SelectionMode.TopLevel);
            Array.Sort(textures, (UnityEngine.Object one, UnityEngine.Object two) => one.name.CompareTo(two.name));
            bool selectionIsValid = ValidateTextures(textures);

            if(selectionIsValid == false)
            {
                Debug.LogError("Unable to create TextureArray; Please check all files have the same width/height/format.");
                return;
            }

            Texture2DArray textureArray = new Texture2DArray(textures[0].width, textures[0].height, textures.Length, textures[0].format, true);
            string assetPath = AssetDatabase.GetAssetPath(textures[0]);
            assetPath = assetPath.Remove(assetPath.LastIndexOf('/')) + "/GeneratedTextureArray.asset";

            for(int i = 0; i< textures.Length; i++)
            {
                for(int mipMap = 0; mipMap < textures[i].mipmapCount; mipMap++)
                {
                    Graphics.CopyTexture(textures[i], 0, mipMap, textureArray, i, mipMap);
                }
            }

            AssetDatabase.CreateAsset(textureArray, assetPath);
            AssetDatabase.SaveAssets();
            Debug.Log(String.Format("Texture Array successfully created at {0}!", assetPath));
            Selection.activeObject = textureArray;
        }

        private static bool ValidateTextures(Texture2D[] textures)
        {
            for(int i = 1; i < textures.Length; i++)
            {
                if((textures[i].width != textures[0].width)
                    || (textures[i].height != textures[0].height)
                    || (textures[i].format != textures[0].format))
                {
                    return false;
                }
            }
            return true;
        }

        [MenuItem("Assets/Sayi Tools/Create Texture Array", true)]
        private static bool Texture2DArrayCreatorValidation()
        {
            return Selection.GetFiltered<Texture2D>(SelectionMode.TopLevel).Length > 0;
        }
        #endregion
    }
}