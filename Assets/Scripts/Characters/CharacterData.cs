using UnityEngine;
[CreateAssetMenu(menuName="Ecos do Encantado/Character Data")]
public class CharacterData : ScriptableObject
{
    public string id="character",displayName="Aventureiro"; public int maxHp=100,maxEnergy=20,attackPower=12,defense=5;
    public Sprite portrait,body;
}