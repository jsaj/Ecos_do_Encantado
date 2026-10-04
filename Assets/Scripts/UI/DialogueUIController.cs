using UnityEngine; using UnityEngine.UI;
public class DialogueUIController : MonoBehaviour
{
    public DialogueManager manager; public Text speakerLabel,dialogueLabel; public Button nextButton; public Button[] optionButtons;
    void Start(){if(manager==null)manager=GetComponent<DialogueManager>();if(manager!=null)manager.NodeChanged+=Show; if(nextButton)nextButton.onClick.AddListener(()=>manager?.Next());for(int i=0;i<optionButtons.Length;i++){int n=i;if(optionButtons[i])optionButtons[i].onClick.AddListener(()=>manager?.SelectOption(n));}}
    void OnDestroy(){if(manager!=null)manager.NodeChanged-=Show;}
    void Show(DialogueNode n){if(speakerLabel)speakerLabel.text=n.speaker;if(dialogueLabel)dialogueLabel.text=n.text;for(int i=0;i<optionButtons.Length;i++){var b=optionButtons[i];if(!b)continue;bool v=n.options!=null&&i<n.options.Count;b.gameObject.SetActive(v);if(v)b.GetComponentInChildren<Text>().text=n.options[i].text;if(nextButton)nextButton.gameObject.SetActive(!v);}}
}