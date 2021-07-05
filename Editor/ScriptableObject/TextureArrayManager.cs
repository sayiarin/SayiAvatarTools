using UnityEngine;

namespace SayiTools
{
    [CreateAssetMenu(fileName = "TextureArrayManager", menuName = "SayiTools/Texture Array Manager", order = 1)]
    public class TextureArrayManager : ScriptableObject
    {
        public Texture2DArray textureArray;
        public Texture2D[] textures = new Texture2D[] { };
    }
}