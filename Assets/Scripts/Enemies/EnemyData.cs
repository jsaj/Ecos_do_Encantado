using UnityEngine;
[CreateAssetMenu(menuName="Ecos do Encantado/Enemy Data")]
public class EnemyData : ScriptableObject
{
    public string id="enemy",displayName="Curupira"; public int maxHp=130,maxEnergy=30,attackPower=35,defense=4;
    public Sprite portrait,body; public int experienceReward=25,goldReward=10;
}