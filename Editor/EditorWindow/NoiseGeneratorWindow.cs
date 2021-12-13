using UnityEngine;
using UnityEditor;
using System.IO;
using System;

namespace SayiTools
{
    public class NoiseGeneratorWindow : EditorWindow
    {
        private enum TextureSize { x64 = 64, x128 = 128, x256 = 256, x512 = 512, x1024 = 1024, x2048 = 2048 };
        private const string FILE_ENDING = "png";
        private const RenderTextureFormat RENDER_TEXTURE_FORMAT = RenderTextureFormat.ARGB32;
        private const int PREVIEV_SIZE = 300;

        private TextureSize TexSize = TextureSize.x64;
        private float Scale = 10f;

        // base path as fallback, but that the path should be set properly by the
        // context menu that spawns the window
        private string OutputPath = "Assets";
        private string OutputName = "Noise";

        private Texture2D NoiseTexture;

        [MenuItem("Tools/Sayi/Noise Generator", priority = 1)]
        public static void Init()
        {
            GetWindow<NoiseGeneratorWindow>("Noise Generator").Show();
        }

        private void OnEnable()
        {
            NoiseTexture = new Texture2D(64, 64);
        }

        private void OnGUI()
        {
            GUILayout.BeginVertical();
            GUILayout.Space(EditorGUIUtility.singleLineHeight);
            EditorGUIHelper.HeaderLevel2("Noise Generator");
            OutputName = EditorGUILayout.TextField("Name:", OutputName);
            TexSize = (TextureSize)EditorGUILayout.EnumPopup("Texture Size:", TexSize);
            Scale = EditorGUILayout.Slider("Noise Level:", Scale, 1f, 500f);

            if (NoiseTexture)
            {
                GUI.DrawTexture(new Rect(5, 250, PREVIEV_SIZE, PREVIEV_SIZE), NoiseTexture);
            }

            if (GUILayout.Button("Change path for generated file"))
            {
                OutputPath = EditorUtility.OpenFolderPanel("Output path for generated files", "", "");
                if (OutputPath.StartsWith(Application.dataPath))
                {
                    OutputPath = "Assets" + OutputPath.Substring(Application.dataPath.Length);
                }
            }
            if (GUILayout.Button("Generate"))
            {
                GeneratePerlinNoise();
            }

            if (GUILayout.Button("Save"))
            {
                SaveNoise();
            }
            EditorGUILayout.HelpBox(String.Format("Current output folder for generated files:\n{0}", GetOutputPath()), MessageType.Info);

            GUILayout.Space(PREVIEV_SIZE + 10);
            GUILayout.EndVertical();
        }

        private void GeneratePerlinNoise()
        {
            int size = (int)TexSize;
            Color[] pixels = new Color[size*size];
            NoiseTexture.Resize(size, size);

            for (float y = 0.0f; y < size; y += 1.0f)
            {
                for (float x = 0.0f; x < size; x += 1.0f)
                {
                    float xCoord = x / size * Scale;
                    float yCoord = y / size * Scale;
                    float sample = Mathf.PerlinNoise(xCoord, yCoord);
                    pixels[(int)(y*size + x)]= new Color(sample,sample,sample);
                }
            }

            NoiseTexture.SetPixels(pixels);
            NoiseTexture.Apply();
        }

        private void SaveNoise()
        {
            if (!NoiseTexture)
            {
                Debug.LogError("You have to generate the Noise before saving it :>");
                return;
            }

            byte[] textureData = NoiseTexture.EncodeToPNG();
            File.WriteAllBytes(GetOutputPath(), textureData);

            // refreshing after file has been written, it works on my machine lol
            AssetDatabase.Refresh();
        }

        private RenderTexture CreateRenderTexture(int size)
        {
            RenderTexture renderTexture = new RenderTexture(size, size, 0, RENDER_TEXTURE_FORMAT);
            renderTexture.enableRandomWrite = true;
            renderTexture.wrapMode = TextureWrapMode.Repeat;
            renderTexture.Create();
            return renderTexture;
        }

        private void DrawComputeShaderNotFoundError()
        {
            GUIStyle style = new GUIStyle();
            style.fontStyle = FontStyle.Bold;
            style.normal.textColor = Color.red;
            style.alignment = TextAnchor.MiddleCenter;
            style.wordWrap = true;
            EditorGUILayout.LabelField("Compute shader not found! Please make sure you download the full project from my gitlab and the PerlinNoiseGenerator.compute file exists at the correct location!", style);
            if (GUILayout.Button("Close"))
            {
                this.Close();
            }
        }

        public void SetOutputPath(string outputPath)
        {
            this.OutputPath = outputPath;
        }

        private string GetOutputPath()
        {
            return $"{OutputPath}/{OutputName}.{FILE_ENDING}";
        }
    }
}