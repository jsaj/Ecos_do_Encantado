using UnityEngine;
using UnityEngine.SceneManagement;
public static class SceneManagerController
{
    public static bool IsLoading{get;private set;} public static string ReturnScene="";
    public static void Load(string sceneName){if(IsLoading||string.IsNullOrWhiteSpace(sceneName))return;IsLoading=true;SceneManager.sceneLoaded+=Loaded;SceneManager.LoadScene(sceneName);}
    static void Loaded(Scene s,LoadSceneMode m){IsLoading=false;SceneManager.sceneLoaded-=Loaded;}
    public static void LoadWithReturn(string sceneName){ReturnScene=SceneManager.GetActiveScene().name;Load(sceneName);}
    public static void Return(string fallback){var target=string.IsNullOrEmpty(ReturnScene)?fallback:ReturnScene;ReturnScene="";Load(target);}
}