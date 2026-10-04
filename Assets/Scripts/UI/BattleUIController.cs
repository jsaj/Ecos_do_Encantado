using UnityEngine; using UnityEngine.UI;
public class BattleUIController : MonoBehaviour
{
    public CombatManager combat; public Image playerPortrait,enemyPortrait,playerHp,enemyHp,playerEnergy; public Text playerName,enemyName,turnLabel,logText; public Button attackButton; public SkillData[] skills; public Transform skillContainer; public Button skillButtonPrefab;
    void Start(){if(combat==null)combat=GetComponent<CombatManager>();if(combat!=null){combat.CombatantsChanged+=Refresh;combat.LogMessage+=Log;}if(attackButton!=null)attackButton.onClick.AddListener(()=>combat?.PlayerAttack());}
    void OnDestroy(){if(combat!=null){combat.CombatantsChanged-=Refresh;combat.LogMessage-=Log;}}
    void Refresh(BattleCombatant p,BattleCombatant e){if(playerName)playerName.text=p.displayName;if(enemyName)enemyName.text=e.displayName;if(playerPortrait)playerPortrait.sprite=p.portrait;if(enemyPortrait)enemyPortrait.sprite=e.portrait;if(playerHp)playerHp.fillAmount=p.HpRatio;if(enemyHp)enemyHp.fillAmount=e.HpRatio;if(playerEnergy)playerEnergy.fillAmount=p.EnergyRatio;if(turnLabel&&combat.turns)turnLabel.text="TURNO "+combat.turns.TurnNumber+" — "+(combat.turns.State==CombatState.PlayerTurn?p.displayName:e.displayName);}
    void Log(string s){if(logText)logText.text+=s+"\n";}
}