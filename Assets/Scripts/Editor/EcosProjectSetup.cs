#if UNITY_EDITOR
using UnityEditor; using UnityEditor.SceneManagement; using UnityEngine; using UnityEngine.SceneManagement; using System.IO;
public static class EcosProjectSetup
{
    const string Root="Assets/";
    [MenuItem("Ecos do Encantado/Setup Project")]
    public static void Setup(){EnsureFolders();CreateDataAssets();CreateScenes();AssetDatabase.SaveAssets();AssetDatabase.Refresh();Debug.Log("Ecos do Encantado: Unity project setup complete.");}
    static void EnsureFolders(){string[] fs={"Art","Art/Backgrounds","Art/Characters","Art/Enemies","Art/UI","Art/Icons","Audio","Data","Prefabs","Scenes","Scenes/UI","Scripts","Tests"};foreach(var f in fs){var p=Root+f;if(!AssetDatabase.IsValidFolder(p)){var parent=Path.GetDirectoryName(p).Replace("\\","/");AssetDatabase.CreateFolder(parent,Path.GetFileName(p));}}}
    static void CreateDataAssets(){CreateIfMissing<CharacterData>("Assets/Data/Player_Caipora.asset",x=>{x.id="caipora";x.displayName="Caipora";x.maxHp=150;x.maxEnergy=77;x.attackPower=12;x.defense=5;});CreateIfMissing<EnemyData>("Assets/Data/Enemy_Curupira.asset",x=>{x.id="curupira";x.displayName="Curupira";x.maxHp=130;x.maxEnergy=30;x.attackPower=35;x.defense=4;x.experienceReward=25;x.goldReward=10;});CreateIfMissing<SkillData>("Assets/Data/Skill_Investida.asset",x=>{x.id="investida";x.name="Investida";x.description="Investida Flamejante com chance de crítico.";x.damageBase=35;x.energyCost=10;x.critical=15;});CreateIfMissing<SkillData>("Assets/Data/Skill_Ehuita.asset",x=>{x.id="ehuita";x.name="Ehuita";x.description="Feitiço verde de proteção e cura leve.";x.energyCost=5;});}
    static void CreateIfMissing<T>(string path,System.Action<T> init) where T:ScriptableObject{var a=AssetDatabase.LoadAssetAtPath<T>(path);if(a!=null)return;a=ScriptableObject.CreateInstance<T>();init(a);AssetDatabase.CreateAsset(a,path);}
    static void CreateScenes(){CreateScene("Bootstrap",go=>go.AddComponent<GameManager>());CreateScene("MainMenu",go=>go.AddComponent<Canvas>());CreateScene("WorldMap",go=>{});CreateScene("Exploration",go=>{});CreateScene("Narrative",go=>go.AddComponent<DialogueManager>());CreateScene("Battle",go=>{var t=go.AddComponent<TurnSystem>();var c=go.AddComponent<CombatManager>();c.turns=t;go.AddComponent<BattleUIController>();});}
    static void CreateScene(string name,System.Action<GameObject> setup){var path="Assets/Scenes/"+name+".unity";if(File.Exists(path))return;var scene=EditorSceneManager.NewScene(NewSceneSetup.EmptyScene,NewSceneMode.Single);var root=new GameObject(name);setup(root);EditorSceneManager.SaveScene(scene,path);Object.DestroyImmediate(root);}
}
#endif
