using UnityEngine;
using UnityEditor;

namespace SayiTools
{
    public class TextureHelper : Editor
    {
        public static bool TexturesShareDimensionsAndFormat(Texture2D[] textures)
        {
            if (textures.Length == 0)
            {
                return false;
            }

            if (textures.Length == 1)
            {
                return textures[0];
            }

            for (int i = 1; i < textures.Length; i++)
            {
                if (!textures[i]
                    || (textures[i].width != textures[0].width)
                    || (textures[i].height != textures[0].height)
                    || (textures[i].format != textures[0].format))
                {
                    return false;
                }
            }
            return true;
        }
    }
}