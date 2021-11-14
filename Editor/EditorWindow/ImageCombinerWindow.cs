using UnityEngine;
using UnityEditor;
using System;
using System.Collections.Generic;
using System.IO;

namespace SayiTools
{
    public class ImageCombinerWindow : EditorWindow
    {
        private const string FILE_ENDING = "png";
        private const string ImageInfoMessage = "Combines multiple images into one, using the average colour of a pixel of one image and adding it to the R, G, B, or A channel of the target texture accordingly\nIf no texture is supplied the value will be assumed as 0 (black). Alpha Values in the source images will be discarded.";
        private string OutputPath = "Assets";
        private string OutputName = "CombinedImage";

        private Texture2D ChannelR;
        private Texture2D ChannelG;
        private Texture2D ChannelB;
        private Texture2D ChannelA;

        private bool TexturesValid = true;
        List<Texture2D> Textures = new List<Texture2D>();

        [MenuItem("Tools/Sayi/Image Combiner")]
        public static void Init()
        {
            GetWindow<ImageCombinerWindow>("Image Combiner").Show();
        }

        private void OnGUI()
        {
            EditorGUILayout.BeginVertical();
            GUILayout.Space(EditorGUIUtility.singleLineHeight);
            EditorGUIHelper.HeaderLevel2("Image Combiner");
            EditorGUILayout.HelpBox(ImageInfoMessage, MessageType.Info);
            GUILayout.Space(EditorGUIUtility.singleLineHeight);

            ChannelR = (Texture2D)EditorGUILayout.ObjectField("Red Channel Image", ChannelR, typeof(Texture2D), false);
            ChannelG = (Texture2D)EditorGUILayout.ObjectField("Green Channel Image", ChannelG, typeof(Texture2D), false);
            ChannelB = (Texture2D)EditorGUILayout.ObjectField("Blue Channel Image", ChannelB, typeof(Texture2D), false);
            ChannelA = (Texture2D)EditorGUILayout.ObjectField("Alpha Channel Image", ChannelA, typeof(Texture2D), false);

            // maybe not optimal to use a List<> here, but it's fast enough for this limited dataset
            // and will be very helpful later too
            Textures.Clear();
            if (ChannelR) Textures.Add(ChannelR);
            if (ChannelG) Textures.Add(ChannelG);
            if (ChannelB) Textures.Add(ChannelB);
            if (ChannelA) Textures.Add(ChannelA);

            TexturesValid = TextureHelper.TexturesShareDimensionsAndFormat(Textures.ToArray());
            if (Textures.Count != 0 && TexturesValid == false)
            {
                EditorGUILayout.HelpBox("All images have to be the same size!", MessageType.Error);
            }

            List<string> nonReadableFiles = new List<string>();
            foreach (Texture2D texture in Textures)
            {
                if (!texture.isReadable)
                {
                    nonReadableFiles.Add(texture.name);
                }
            }

            if (nonReadableFiles.Count != 0)
            {
                EditorGUILayout.HelpBox(String.Format("The following images are not readable, please change the import settings of the Textures to 'Read/Write Enabled':\n{0}", String.Join(", ", nonReadableFiles)), MessageType.Error);
                if (GUILayout.Button("Auto Fix"))
                {
                    foreach (Texture2D texture in Textures)
                    {
                        TextureImporter texImporter = (TextureImporter)AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(texture));
                        texImporter.isReadable = true;
                        texImporter.SaveAndReimport();
                    }
                }
            }

            GUILayout.Space(EditorGUIUtility.singleLineHeight);
            OutputName = EditorGUILayout.TextField("Name:", OutputName);
            if (GUILayout.Button("Change path for generated file"))
            {
                OutputPath = EditorUtility.OpenFolderPanel("Output path for generated files", "", "");
                if (OutputPath.StartsWith(Application.dataPath))
                {
                    OutputPath = "Assets" + OutputPath.Substring(Application.dataPath.Length);
                }
            }
            EditorGUI.BeginDisabledGroup(!TexturesValid || Textures.Count == 0 || nonReadableFiles.Count != 0);
            if (GUILayout.Button("Save"))
            {
                CombineAndSaveImage();
            }
            EditorGUI.EndDisabledGroup();
            EditorGUILayout.HelpBox(String.Format("Current output folder for generated files:\n{0}", GetOutputPath()), MessageType.Info);
            EditorGUILayout.EndVertical();
        }

        private void CombineAndSaveImage()
        {
            Texture2D combinedTexture = new Texture2D(Textures[0].width, Textures[0].height);

            for (int y = 0; y < Textures[0].width; y++)
            {
                for (int x = 0; x < Textures[0].height; x++)
                {
                    float redChannel = SampleAverageScalarFromTexture(ChannelR, x, y);
                    float greenChannel = SampleAverageScalarFromTexture(ChannelG, x, y);
                    float blueChannel = SampleAverageScalarFromTexture(ChannelB, x, y);
                    float alphaChannel = SampleAverageScalarFromTexture(ChannelA, x, y);
                    Color combinedColor = new Color(redChannel, greenChannel, blueChannel, alphaChannel);
                    combinedTexture.SetPixel(x, y, combinedColor);
                }
            }

            combinedTexture.Apply();
            byte[] bytes = combinedTexture.EncodeToPNG();
            File.WriteAllBytes(GetOutputPath(), bytes);
            AssetDatabase.Refresh();
        }

        private float SampleAverageScalarFromTexture(Texture2D texture, int x, int y)
        {
            if (texture)
            {
                Color color = texture.GetPixel(x, y);
                float combinedScalarValue = color.r + color.g + color.b;
                if (combinedScalarValue == 0)
                {
                    return 0.0f;
                }
                return combinedScalarValue / 3;
            }
            return 0.0f;
        }

        private string GetOutputPath()
        {
            return $"{OutputPath}/{OutputName}.{FILE_ENDING}";
        }
    }
}