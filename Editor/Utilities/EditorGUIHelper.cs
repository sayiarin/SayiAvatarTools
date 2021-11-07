using UnityEngine;
using UnityEditor;

namespace SayiTools
{
    public class EditorGUIHelper : Editor
    {
        public static void HeaderLevel1(string headerText)
        {
            Header(headerText, 18, Color.cyan);
        }

        public static void HeaderLevel2(string headerText)
        {
            Header(headerText, 14, Color.cyan);
        }

        public static void Separator()
        {
            GUILayout.Space(5);
            Rect rect = EditorGUILayout.GetControlRect(GUILayout.Height(2));
            rect.height = 2;
            EditorGUI.DrawRect(rect, new Color(0, 0, 0, 0.15f));
            GUILayout.Space(5);
        }

        private static void Header(string headerText, int fontSize, Color colour)
        {
            GUIStyle headerStyle = new GUIStyle();
            headerStyle.fontStyle = FontStyle.Bold;
            headerStyle.fontSize = fontSize;
            headerStyle.normal.textColor = colour;
            headerStyle.alignment = TextAnchor.MiddleCenter;
            GUILayout.Label(headerText, headerStyle);
            EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);
            GUILayout.Space(EditorGUIUtility.singleLineHeight);
        }
    }
}