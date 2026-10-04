using System;
using System.Collections.Generic;
[Serializable] public class PlayerState { public string name="Aventureiro"; public int hp=100,maxHp=100,energy=20,maxEnergy=20,gold=25,level=1,xp=0,xpNextLevel=100; }
[Serializable] public class AttributesState { public int force=10,dexterity=10,intellect=10,vigor=10,luck=10,spirit=10; }
[Serializable] public class TimeState { public int day=1,hour=8,minute=0; public string season="primavera"; }
public class GameState
{
    public PlayerState Player=new PlayerState(); public AttributesState Attributes=new AttributesState();
    public List<string> Inventory=new List<string>(); public List<string> Party=new List<string>();
    public string CurrentRegion="",CurrentScene="",CurrentQuest=""; public Dictionary<string,bool> Flags=new();
    public List<string> ChoicesMade=new(); public int Karma=0; public TimeState Time=new TimeState();
    public Dictionary<string,int> Reputation=new(){["aldeia_das_aguas"]=0,["curupiras"]=0,["bandeirantes_fantasmas"]=0};
    public bool InCombat=false; public string CurrentEnemy=""; public int TurnCount=0;
    public void Reset(){ Player=new PlayerState(); Attributes=new AttributesState(); Inventory.Clear(); Party.Clear(); CurrentRegion=CurrentScene=CurrentQuest=""; Flags.Clear(); ChoicesMade.Clear(); Karma=0; Time=new TimeState(); Reputation=new(){["aldeia_das_aguas"]=0,["curupiras"]=0,["bandeirantes_fantasmas"]=0}; InCombat=false; CurrentEnemy=""; TurnCount=0; }
    public void SetFlag(string key,bool value)=>Flags[key]=value;
    public bool GetFlag(string key)=>Flags.TryGetValue(key,out var v)&&v;
    public void AddGold(int amount)=>Player.gold+=amount;
    public bool SpendGold(int amount){if(Player.gold<amount)return false;Player.gold-=amount;return true;}
    public void AddXp(int amount){Player.xp+=amount;while(Player.xp>=Player.xpNextLevel){Player.xp-=Player.xpNextLevel;Player.level++;Player.xpNextLevel=Mathf.Max(1,Mathf.RoundToInt(Player.xpNextLevel*GameConstants.XpMultiplier));Player.maxHp+=GameConstants.LevelUpHpBonus;Player.hp=Player.maxHp;}}
    public void AdvanceTime(int minutes){Time.minute+=minutes;while(Time.minute>=60){Time.minute-=60;Time.hour++;}while(Time.hour>=24){Time.hour-=24;Time.day++;}}
}