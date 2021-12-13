using UnityEngine;
using UnityEditor;

namespace SayiTools
{
    public class SayiToolsUpdater : EditorWindow
    {
        [MenuItem("Tools/Sayi/Update", priority = 100)]
        public static void Init()
        {
            Debug.LogError("Updater called");
        }
    }
}