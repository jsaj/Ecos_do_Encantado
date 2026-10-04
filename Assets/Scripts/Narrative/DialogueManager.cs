using System; using UnityEngine;
public class DialogueManager : MonoBehaviour
{
    public DialogueData data; public string CurrentNodeId{get;private set;}=""; public DialogueNode CurrentNode{get;private set;}
    public event Action<DialogueNode> NodeChanged; public event Action DialogueFinished;
    public void StartDialogue(DialogueData dialogue,string start="start"){data=dialogue;CurrentNodeId=start;Process();}
    public void Next(){if(CurrentNode==null){End();return;}if(!string.IsNullOrEmpty(CurrentNode.nextNode)){CurrentNodeId=CurrentNode.nextNode;Process();}else if(CurrentNode.options==null||CurrentNode.options.Count==0)End();}
    public void SelectOption(int index){if(CurrentNode?.options==null||index<0||index>=CurrentNode.options.Count)return;var o=CurrentNode.options[index];if(!string.IsNullOrEmpty(o.skill)&&GameManager.Instance!=null){var a=GetAttribute(o.skill);var roll=UnityEngine.Random.Range(1,21);var ok=roll+a>=o.dc;CurrentNodeId=ok?o.successNode:o.failureNode;}else CurrentNodeId=o.nextNode;if(string.IsNullOrEmpty(CurrentNodeId))End();else Process();}
    int GetAttribute(string key){var a=GameManager.Instance.State.Attributes;return key.ToLower() switch{"force"=>a.force,"dexterity"=>a.dexterity,"intellect"=>a.intellect,"vigor"=>a.vigor,"luck"=>a.luck,"spirit"=>a.spirit,_=>10};}
    void Process(){CurrentNode=data?.Get(CurrentNodeId);if(CurrentNode==null){End();return;}NodeChanged?.Invoke(CurrentNode);}
    public void End(){CurrentNode=null;DialogueFinished?.Invoke();}
}