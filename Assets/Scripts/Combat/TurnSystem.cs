using System; using UnityEngine;
public enum CombatState { Waiting,PlayerTurn,PlayerAction,EnemyTurn,EnemyAction,Victory,Defeat }
public class TurnSystem : MonoBehaviour
{
    public CombatState State{get;private set;}=CombatState.Waiting; public int TurnNumber{get;private set;}=1;
    public event Action<int,CombatState> TurnChanged;
    public void Begin(){TurnNumber=1;State=CombatState.PlayerTurn;TurnChanged?.Invoke(TurnNumber,State);}
    public void EndPlayerTurn(){if(State!=CombatState.PlayerTurn)return;TurnNumber++;State=CombatState.EnemyTurn;TurnChanged?.Invoke(TurnNumber,State);}
    public void EndEnemyTurn(){if(State!=CombatState.EnemyTurn)return;State=CombatState.PlayerTurn;TurnChanged?.Invoke(TurnNumber,State);}
    public void SetResult(bool playerWon){State=playerWon?CombatState.Victory:CombatState.Defeat;TurnChanged?.Invoke(TurnNumber,State);}
}