using UnityEngine;
using UnityEditor;

namespace SayiTools {

    public class GeneratePerlinNoiseTexture : ScriptableObject
    {
        [MenuItem("Assets/Sayi Tools/Generate Perlin Noise Texture", false, 100)]
        private static void OpenPerlinNoiseGeneratorWindow()
        {
            NoiseGeneratorWindow window = ScriptableObject.CreateInstance<NoiseGeneratorWindow>();
            window.position = new Rect(Screen.width / 2, Screen.height / 2, 300, 500);
            window.Show();

            string outputPath = "Assets";
            UnityEngine.Object activeObject = Selection.activeObject;
            if (activeObject != null)
            {
                outputPath = AssetDatabase.GetAssetPath(activeObject.GetInstanceID());
                if (AssetDatabase.IsValidFolder(outputPath) == false)
                {
                    outputPath = outputPath.Remove(outputPath.LastIndexOf('/'));
                }
            }
            window.SetOutputPath(outputPath);
        }
    }
}