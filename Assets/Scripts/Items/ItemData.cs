using UnityEngine;
public enum ItemType { Consumable,Equipment,Quest,Material,Special }
[CreateAssetMenu(menuName="Ecos do Encantado/Item Data")]
public class ItemData : ScriptableObject
{
    public string id,name="Novo Item",description; public int price,maxStack=99; public bool stackable=true; public ItemType type;
    public Sprite icon; public int damage,defense,energyRestore,healAmount;
}