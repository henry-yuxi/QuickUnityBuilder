using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class JenkinsBuilder
{
    protected static string BuildOutputPath
    {
        get { return Application.dataPath.Replace("/Assets", "/AutoBuilder"); }
    }

    protected static string GetOutputPath(BuildTarget buildTarget)
    {
        string root = buildTarget == BuildTarget.Android ? "Android" : "IOS";
        return BuildOutputPath + "/" + root + "/";
    }

    #region Jenkins远程打包使用的接口

    public static void ScriptingJenkinsDefineSymbols()
    {
        string target = GetJenkinsParameter("Build_Target");
        if (target == null || !(target.Equals("Android") || target.Equals("iOS")))
        {
            throw new Exception("Log Error: 错误的打包平台参数 : " + target);
        }
        BuildTargetGroup buildTargetGroup = target.Equals("Android") ? BuildTargetGroup.Android : BuildTargetGroup.iOS;
        PlayerSettings.SetScriptingDefineSymbolsForGroup(buildTargetGroup, GetJenkinsParameter("Unity_Define"));
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    public static void JenkinsBuildBundles()
    {
        string target = GetJenkinsParameter("Build_Target");
        if (target == null || !(target.Equals("Android") || target.Equals("iOS")))
        {
            throw new Exception("Log Error: 错误的打包平台参数 : " + target);
        }
        BuildTargetGroup buildTargetGroup = target.Equals("Android") ? BuildTargetGroup.Android : BuildTargetGroup.iOS;
        BuildTarget buildTarget = target.Equals("Android") ? BuildTarget.Android : BuildTarget.iOS;
        SetJenkinsPackParams();
        if (EditorUserBuildSettings.SwitchActiveBuildTarget(buildTargetGroup, buildTarget))
        {
            /*具体的打包资源逻辑*/
        }
    }

    public static void JenkinsBuildPackage()
    {
        string target = GetJenkinsParameter("Build_Target");
        if (target == null || !(target.Equals("Android") || target.Equals("iOS")))
        {
            throw new Exception("Log Error: 错误的打包平台参数 : " + target);
        }
        BuildTargetGroup buildTargetGroup = target.Equals("Android") ? BuildTargetGroup.Android : BuildTargetGroup.iOS;
        BuildTarget buildTarget = target.Equals("Android") ? BuildTarget.Android : BuildTarget.iOS;
        SetJenkinsPackParams();
        if (EditorUserBuildSettings.SwitchActiveBuildTarget(buildTargetGroup, buildTarget))
        {
            string development = GetJenkinsParameter("Development_Build");
            string path = GetJenkinsParameter("Build_Path");
            CheckDir(path);
            var date = DateTime.Now;
            PlayerSettings.bundleVersion = "1." + date.Month + "." + date.Day;
            SetJenkinsPackParams();
            PlayerSettings.SetScriptingDefineSymbolsForGroup(buildTargetGroup, GetJenkinsParameter("Unity_Define"));
            if (buildTargetGroup == BuildTargetGroup.Android)
            {
                //PlayerSettings.Android.keystoreName = ProjectConfig.keystoreName;
                //PlayerSettings.keystorePass = ProjectConfig.keystorePass;
                //PlayerSettings.Android.keyaliasName = ProjectConfig.keyaliasName;
                //PlayerSettings.keyaliasPass = ProjectConfig.keyaliasPass;
                //PlayerSettings.Android.minSdkVersion = ProjectConfig.minSdkVersion;
                //PlayerSettings.Android.targetSdkVersion = ProjectConfig.targetSdkVersion;
                /*安卓平台参数设置*/

            }
            else if (buildTargetGroup == BuildTargetGroup.iOS)
            {
                string method = GetJenkinsParameter("Ipa_Export_Method");
                if (method.Equals("Enterprise"))
                {
                    PlayerSettings.SetApplicationIdentifier(buildTargetGroup, "com.baiyao.ylqt");
                }
                else
                {
                    PlayerSettings.SetApplicationIdentifier(buildTargetGroup, "com.blademaster.ylqt");
                }
            }

            BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions();
            buildPlayerOptions.scenes = GetBuildScenes();
            buildPlayerOptions.locationPathName = Path.Combine(path, GetJenkinsParameter("Build_FileName"));
            buildPlayerOptions.target = buildTarget;
            buildPlayerOptions.options = (development != null && development.Equals("true")) ? BuildOptions.Development : BuildOptions.None;
            BuildPipeline.BuildPlayer(buildPlayerOptions);
        }
    }

    protected static void SetJenkinsPackParams()
    {
        string server = GetJenkinsParameter("Unity_Server");
        string channel = GetJenkinsParameter("Unity_Channel");
        string sdk = GetJenkinsParameter("Unity_SDK");
        string version = GetJenkinsParameter("Bundles_Version");
        if (string.IsNullOrEmpty(server) || string.IsNullOrEmpty(channel) || string.IsNullOrEmpty(sdk) || string.IsNullOrEmpty(version))
        {
            throw new Exception("远程打包参数l错误 ");
        }
        //ServerName = server;
        //Channel = channel;
        //SDK = sdk;
        //Debug.Log("SetJenkinsPackParams SDK=" + SDK);
    }

    #endregion Jenkins远程打包使用的接口

    public static bool CheckDir(string url)
    {
        try
        {
            if (!Directory.Exists(url))
                Directory.CreateDirectory(url);
            return true;
        }
        catch (Exception)
        {
            return false;
        }
    }

    private static string[] GetBuildScenes()
    {
        AssetDatabase.Refresh();
        List<string> scenes = new List<string>();
        foreach (EditorBuildSettingsScene scene in EditorBuildSettings.scenes)
        {
            if (!scene.enabled) continue;
            scenes.Add(scene.path);
        }
        return scenes.ToArray();
    }

    /// <summary>
    /// 获取从Jenkins传过来的自定义参数
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    private static string GetJenkinsParameter(string name)
    {
        foreach (string arg in Environment.GetCommandLineArgs())
        {
            if (arg.StartsWith(name))
            {
                return arg.Split("-"[0])[1];
            }
        }
        return null;
    }

    private static string ResolveExtension(BuildTarget a_target)
    {
        switch (a_target)
        {
            case BuildTarget.StandaloneWindows:
            case BuildTarget.StandaloneWindows64:
                return ".exe";

            case BuildTarget.iOS:
                return ".xcode";

            case BuildTarget.Android:
                return ".apk";

            case BuildTarget.WebGL:
                return ".html";
        }

        return string.Empty;
    }
}
