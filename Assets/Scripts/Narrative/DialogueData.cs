using System; using System.Collections.Generic; using UnityEngine;
[Serializable] public class DialogueOption { public string text,nextNode,successNode,failureNode,skill; public int dc; }
[Serializable] public class DialogueNode { public string id="start",speaker="Desconhecido",text="",mood="Neutro",nextNode; public List<DialogueOption> options=new(); }
[CreateAssetMenu(menuName="Ecos do Encantado/Dialogue Data")]
public class DialogueData : ScriptableObject { public string startNode="start"; public List<DialogueNode> nodes=new(); public DialogueNode Get(string id)=>nodes.Find(n=>n.id==id); }