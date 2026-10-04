using System.Collections.Generic; using UnityEngine;
[System.Serializable] public class ActiveEffect { public string name,kind; public int turns; }
public class BattleCombatant
{
    public string displayName; public int maxHp,hp,maxEnergy,energy,attackPower,defense; public bool isPlayer,hasActed; public Sprite portrait,body; public List<ActiveEffect> effects=new();
    public bool IsAlive=>hp>0; public float HpRatio=>maxHp<=0?0:(float)hp/maxHp; public float EnergyRatio=>maxEnergy<=0?0:(float)energy/maxEnergy;
    public int ReceiveDamage(int amount){var damage=Mathf.Max(amount-defense/2,1);hp=Mathf.Max(hp-damage,0);return damage;}
    public bool SpendEnergy(int amount){if(energy<amount)return false;energy-=amount;return true;}
    public void Heal(int amount)=>hp=Mathf.Min(maxHp,hp+amount);
    public void ResetTurn()=>hasActed=false;
}