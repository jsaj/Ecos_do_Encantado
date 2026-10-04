using System.Collections.Generic; using UnityEngine;
[System.Serializable] public class InventoryEntry { public ItemData item; public int quantity=1; }
public class InventorySystem : MonoBehaviour
{
    public List<InventoryEntry> entries=new();
    public bool Add(ItemData item,int amount=1){if(item==null||amount<=0)return false;var e=entries.Find(x=>x.item==item);if(e!=null&&item.stackable){e.quantity=Mathf.Min(e.quantity+amount,item.maxStack);return true;}entries.Add(new InventoryEntry{item=item,quantity=Mathf.Min(amount,item.maxStack)});return true;}
    public bool Remove(ItemData item,int amount=1){var e=entries.Find(x=>x.item==item);if(e==null||e.quantity<amount)return false;e.quantity-=amount;if(e.quantity==0)entries.Remove(e);return true;}
    public int Count(ItemData item){var e=entries.Find(x=>x.item==item);return e?.quantity??0;}
}