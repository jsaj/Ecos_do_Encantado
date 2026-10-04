using UnityEngine;
public class GameManager : MonoBehaviour
{
    public static GameManager Instance {get; private set;} public GameState State {get; private set;}=new GameState();
    public bool IsPaused{get;private set;} public event System.Action GameStarted,GamePaused,GameResumed,GameEnded;
    void Awake(){if(Instance!=null&&Instance!=this){Destroy(gameObject);return;}Instance=this;DontDestroyOnLoad(gameObject);}
    public void StartNewGame(){State.Reset();IsPaused=false;GameStarted?.Invoke();SceneManagerController.Load("WorldMap");}
    public void LoadGame(){GameStarted?.Invoke();SceneManagerController.Load("WorldMap");}
    public void PauseGame(){if(IsPaused)return;IsPaused=true;Time.timeScale=0;GamePaused?.Invoke();}
    public void ResumeGame(){if(!IsPaused)return;IsPaused=false;Time.timeScale=1;GameResumed?.Invoke();}
    public void TogglePause(){if(IsPaused)ResumeGame();else PauseGame();}
    public void QuitGame(){GameEnded?.Invoke();Application.Quit();}
    public void GoToMenu()=>SceneManagerController.Load("MainMenu");
}