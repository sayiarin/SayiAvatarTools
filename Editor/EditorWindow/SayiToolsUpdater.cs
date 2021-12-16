using UnityEngine;
using UnityEditor;
using UnityEngine.Networking;
using System.IO.Compression;
using System.IO;
using System.Collections.Generic;

namespace SayiTools
{
    public class SayiToolsUpdater : EditorWindow
    {
        private enum WebRequestState
        {
            None,
            InProgress,
            Error,
            Success
        }

        private const string VERSION_URL = "https://gitlab.com/sayiarin/sayiavatartools/-/raw/main/version.txt";
        private const string ZIP_URL = "https://gitlab.com/sayiarin/sayiavatartools/-/archive/main/sayiavatartools-main.zip";
        private const string ZIP_ROOT_FOLDER = "sayiavatartools-main/";

        private static UnityWebRequest VersionRequest;
        private static WebRequestState VersionRequestState = WebRequestState.None;

        private static UnityWebRequest UpdateDownloadRequest;
        private static WebRequestState UpdateDownloadRequestState = WebRequestState.None;

        private List<string> DownloadedFileList = new List<string>();

        private TextAsset ChangelogAsset;
        private Vector2 ChangelogScrollPosition;

        // unity has an enum called Version that masks this one >.<
        private System.Version RemoteVersion;
        private System.Version LocalVersion;

        [MenuItem("Tools/Sayi/Update", priority = 100)]
        public static void Init()
        {
            GetWindow<SayiToolsUpdater>("SayiTools Updater").Show();
        }

        private void OnGUI()
        {
            EditorGUILayout.Space(EditorGUIUtility.singleLineHeight);
            EditorGUIHelper.HeaderLevel2("SayiTools Updater");

            // automatically check for an update the first time the window is opened
            if (RemoteVersion == null && VersionRequestState == WebRequestState.None)
            {
                CheckForUpdate();
            }

            EditorGUI.BeginDisabledGroup(VersionRequestState == WebRequestState.InProgress);
            if (GUILayout.Button("Check for Updates"))
            {
                CheckForUpdate();
            }
            EditorGUI.EndDisabledGroup();

            switch (VersionRequestState)
            {
                case WebRequestState.None:
                    break;
                case WebRequestState.InProgress:
                    EditorGUILayout.LabelField("Fetching Version Data");
                    break;
                case WebRequestState.Error:

                    EditorGUILayout.HelpBox(string.Format("Encountered an error while fetching Version:\n{0}", VersionRequest.error), MessageType.Error);
                    break;
                case WebRequestState.Success:
                    ShowUpdateInfo();
                    break;
            }

            EditorGUILayout.Space(EditorGUIUtility.singleLineHeight);
            EditorGUILayout.LabelField("local Changelog:");
            if (ChangelogAsset == null)
            {
                ChangelogAsset = AssetDatabase.LoadAssetAtPath<TextAsset>(EditorHelper.GetPathInSayiTools("changelog.txt"));
            }

            ChangelogScrollPosition = GUILayout.BeginScrollView(ChangelogScrollPosition);
            EditorGUI.BeginDisabledGroup(true);
            EditorStyles.textArea.wordWrap = true;
            EditorGUILayout.TextArea(ChangelogAsset.text, EditorStyles.textArea);
            EditorGUI.EndDisabledGroup();
            GUILayout.EndScrollView();
        }

        private void ShowUpdateInfo()
        {
            if (RemoteVersion == null)
            {
                RemoteVersion = new System.Version(VersionRequest.downloadHandler.text);
            }
            if (LocalVersion == null)
            {
                UpdateLocalVersion();
            }
            EditorGUILayout.Space(EditorGUIUtility.singleLineHeight);
            EditorGUIHelper.FlexSpaceText("Remote Version:", RemoteVersion.ToString());
            EditorGUIHelper.FlexSpaceText("Local Version:", LocalVersion.ToString());
            EditorGUILayout.Space(EditorGUIUtility.singleLineHeight);

            if (RemoteVersion > LocalVersion)
            {
                EditorGUILayout.HelpBox("An update is available.\nPlease note that the automatic updater will override all local changes within the Sayi Avatar Tools root folder!", MessageType.Warning);
                EditorGUI.BeginDisabledGroup(UpdateDownloadRequestState != WebRequestState.None);
                if (GUILayout.Button("Update"))
                {
                    UpdateDownloadRequest = UnityWebRequest.Get(ZIP_URL);
                    UpdateDownloadRequest.SendWebRequest();
                    UpdateDownloadRequestState = WebRequestState.InProgress;
                    EditorApplication.update += UpdateDownload;
                }
                EditorGUI.EndDisabledGroup();

                switch (UpdateDownloadRequestState)
                {
                    case WebRequestState.None:
                        break;
                    case WebRequestState.InProgress:
                        break;
                    case WebRequestState.Error:
                        EditorGUILayout.HelpBox(string.Format("Encountered an error while fetching Version:\n{0}", UpdateDownloadRequest.error), MessageType.Error);
                        break;
                    case WebRequestState.Success:
                        try
                        {
                            AssetDatabase.StartAssetEditing();
                            UpdateFiles();
                        }
                        finally
                        {
                            AssetDatabase.StopAssetEditing();
                        }
                        break;
                }
            }
            else
            {
                EditorGUILayout.HelpBox("You are up to date!", MessageType.Info);
            }
        }

        private void UpdateLocalVersion()
        {
            TextAsset versionFile = AssetDatabase.LoadAssetAtPath<TextAsset>(EditorHelper.GetPathInSayiTools("version.txt"));
            LocalVersion = new System.Version(versionFile.text);
        }

        private void CheckForUpdate()
        {
            VersionRequestState = WebRequestState.InProgress;
            VersionRequest = UnityWebRequest.Get(VERSION_URL);
            VersionRequest.SendWebRequest();
            EditorApplication.update += VersionRequestUpdate;
            LocalVersion = null;
            RemoteVersion = null;
            UpdateDownloadRequestState = WebRequestState.None;
        }

        private void UpdateFiles()
        {
            EditorUtility.DisplayProgressBar(EditorGUIHelper.GetProgressBarTitle("Updater"), "Writing new files ...", 0);
            // set back to none so that all that happens here is done only once
            UpdateDownloadRequestState = WebRequestState.None;
            DownloadedFileList.Clear();

            MemoryStream zipStream = new MemoryStream(UpdateDownloadRequest.downloadHandler.data);
            using (var zip = new ZipArchive(zipStream, ZipArchiveMode.Read))
            {
                for (int i = 0; i < zip.Entries.Count; i++)
                {
                    var entry = zip.Entries[i];
                    string pathName = entry.FullName.Substring(ZIP_ROOT_FOLDER.Length);
                    if (string.IsNullOrWhiteSpace(pathName))
                    {
                        continue;
                    }
                    pathName = EditorHelper.GetPathInSayiTools(pathName);
                    DownloadedFileList.Add(pathName);
                    if (pathName.EndsWith("/"))
                    {
                        Directory.CreateDirectory(pathName);
                    }
                    else
                    {
                        using (var dataStream = new MemoryStream())
                        {
                            entry.Open().CopyTo(dataStream);
                            File.WriteAllBytes(pathName, dataStream.ToArray());
                        }
                    }
                    EditorUtility.DisplayProgressBar(EditorGUIHelper.GetProgressBarTitle("Updater"), "Writing new files ...", (float)i / zip.Entries.Count);
                }
            }
            EditorUtility.DisplayProgressBar(EditorGUIHelper.GetProgressBarTitle("Updater"), "Removing old files ...", 0.5f);
            RemoveOldFiles(EditorHelper.GetPathInSayiTools());
            EditorUtility.ClearProgressBar();
            UpdateLocalVersion();
        }

        private void RemoveOldFiles(string path)
        {
            foreach (var file in Directory.GetFiles(path))
            {
                if (DownloadedFileList.Contains(file) == false)
                {
                    File.Delete(file);
                }
            }
            foreach (var directory in Directory.GetDirectories(path))
            {
                if (directory.Contains("/.git/"))
                {
                    // ignore git directory
                    continue;
                }
                if (DownloadedFileList.Contains(directory))
                {
                    RemoveOldFiles(path);
                }
                else
                {
                    Directory.Delete(directory, true);
                }
            }
        }

        private static void VersionRequestUpdate()
        {
            if (!VersionRequest.isDone)
            {
                return;
            }
            if (VersionRequest.isNetworkError)
            {
                VersionRequestState = WebRequestState.Error;
                Debug.LogError(VersionRequest.error);
            }
            else
            {
                VersionRequestState = WebRequestState.Success;
            }
            EditorApplication.update -= VersionRequestUpdate;
        }
        private static void UpdateDownload()
        {
            if (!UpdateDownloadRequest.isDone)
            {
                bool canceled = EditorUtility.DisplayCancelableProgressBar(EditorGUIHelper.GetProgressBarTitle("Updater"), "Downloading Files ...", UpdateDownloadRequest.downloadProgress);
                if (canceled)
                {
                    UpdateDownloadRequest.Abort();
                    UpdateDownloadRequest.Dispose();
                    UpdateDownloadRequestState = WebRequestState.None;
                    EditorUtility.ClearProgressBar();
                    EditorApplication.update -= UpdateDownload;
                }
                return;
            }
            if (UpdateDownloadRequest.isNetworkError)
            {
                UpdateDownloadRequestState = WebRequestState.Error;
                Debug.LogError(UpdateDownloadRequest.error);
            }
            else
            {
                UpdateDownloadRequestState = WebRequestState.Success;
            }
            EditorUtility.ClearProgressBar();
            EditorApplication.update -= UpdateDownload;
        }

        private void OnDestroy()
        {
            // when window is closed reset everything
            VersionRequestState = WebRequestState.None;
            UpdateDownloadRequestState = WebRequestState.None;

            if (VersionRequest != null)
            {
                VersionRequest.Abort();
                VersionRequest.Dispose();
            }
            if (UpdateDownloadRequest != null)
            {
                UpdateDownloadRequest.Abort();
                UpdateDownloadRequest.Dispose();
            }

            LocalVersion = null;
            RemoteVersion = null;
        }
    }
}