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

    public static void JenkinsBuildAndroid()
    {
        JenkinsBuildCommon(BuildTargetGroup.Android, BuildTarget.Android);
    }

    public static void JenkinsBuildIOS()
    {
        JenkinsBuildCommon(BuildTargetGroup.iOS, BuildTarget.iOS);
    }

    protected static void JenkinsBuildCommon(BuildTargetGroup group, BuildTarget target)
    {
        BuildChannelINI(GetJenkinsParameter("Unity_Channel"));
        if (EditorUserBuildSettings.SwitchActiveBuildTarget(group, target))
        {
            string development = GetJenkinsParameter("Development_Build");
            string path = GetJenkinsParameter("Build_Path");
            CheckDir(path);
            BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions();
            buildPlayerOptions.scenes = GetBuildScenes();
            buildPlayerOptions.locationPathName = Path.Combine(path, GetJenkinsParameter("Build_FileName"));
            buildPlayerOptions.target = target;
            buildPlayerOptions.options = (development != null && development.Equals("true")) ? BuildOptions.Development : BuildOptions.None;
            BuildPipeline.BuildPlayer(buildPlayerOptions);
        }
    }

    public static void JenkinsBuildAndroidBundles()
    {
        JenkinsBuildBundlesCommon(BuildTargetGroup.Android, BuildTarget.Android);
    }

    public static void JenkinsBuildIOSBundles()
    {
        JenkinsBuildBundlesCommon(BuildTargetGroup.iOS, BuildTarget.iOS);
    }

    protected static void JenkinsBuildBundlesCommon(BuildTargetGroup group, BuildTarget target)
    {
        ApplyJenkinsParameter(target);

        if (EditorUserBuildSettings.SwitchActiveBuildTarget(group, target))
        {

        }
    }

    public static void JenkinsOnekeyBuildAndroid()
    {
        JenkinsOnekeyBuildCommon(BuildTargetGroup.Android, BuildTarget.Android);
    }

    public static void JenkinsOnekeyBuildIOS()
    {
        JenkinsOnekeyBuildCommon(BuildTargetGroup.iOS, BuildTarget.iOS);
    }

    protected static void JenkinsOnekeyBuildCommon(BuildTargetGroup group, BuildTarget target)
    {
        ApplyJenkinsParameter(target);

        if (EditorUserBuildSettings.SwitchActiveBuildTarget(group, target))
        {

            JenkinsBuildCommon(group, target);
        }
    }

    protected static void ApplyJenkinsParameter(BuildTarget target)
    {
        string channel = GetJenkinsParameter("Unity_Channel");
        if (string.IsNullOrEmpty(channel))
        {
            Debug.LogError("远程打包参数Unity_Channel错误 ");
            return;
        }

        string version = GetJenkinsParameter("Bundles_Version");
        if (string.IsNullOrEmpty(version))
        {
            Debug.LogError("远程打包参数Bundles_Version错误 ");
            return;
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        Debug.Log("Apply Jenkins Channe Finished, Current Channel : ");
    }

    private static void BuildChannelINI(string channel)
    {
        if (string.IsNullOrEmpty(channel))
        {
            Debug.LogError("参数Channel错误 ");
            return;
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        Debug.Log("Channel INI Write Finished, Current Channel : " + channel);
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
