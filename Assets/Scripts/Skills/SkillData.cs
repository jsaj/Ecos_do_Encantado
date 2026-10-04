using UnityEngine;
public enum SkillType { Physical,Magical,Utility }
[CreateAssetMenu(menuName="Ecos do Encantado/Skill Data")]
public class SkillData : ScriptableObject
{
    public string id,name="Nova Habilidade",description; public int energyCost=5,damageBase=10,manaCost=0,critical=0,staminaCost=0; public SkillType type;
    public Sprite icon;
}