# UNITY_ASSET_SETUP — Ecos do Encantado

## Importação
Abra o projeto na Unity 2022.3 LTS. Os arquivos PNG/GIF/SVG podem ser importados normalmente. Os arquivos Godot .import não fazem parte da implementação Unity.

## Estrutura
- Assets/Art/Backgrounds: fundos.
- Assets/Art/Characters: personagens/jogador.
- Assets/Art/Enemies: inimigos.
- Assets/Art/UI: molduras, botões e elementos de interface.
- Assets/Art/Icons: ícones.
- Assets/Data: ScriptableObjects.
- Assets/Prefabs: prefabs.
- Assets/Scenes: Bootstrap, MainMenu, WorldMap, Exploration, Narrative e Battle.

## Imagens e sprites
Selecione uma imagem em Assets/Art e confirme Texture Type = Sprite (2D and UI). Para personagens/inimigos preserve transparência. Para fundos use Sprite Mode = Single.

## Personagens e inimigos
No Player_Caipora.asset preencha Portrait e Body com os sprites correspondentes. No Enemy_Curupira.asset preencha Portrait e Body.

## Backgrounds
Na cena Battle use um Canvas ou SpriteRenderer para o fundo e atribua Assets/Art/Backgrounds/bg_front_game.png. A referência visual do projeto é 1080 x 1920.

## Ícones, habilidades e itens
Crie ou edite SkillData e ItemData. Arraste os ícones para Icon. Os campos de dano/custo substituem os dados equivalentes do Godot.

## Barras de HP/Energia
Use Image com Image Type = Filled e Fill Method = Horizontal. Atribua as imagens aos campos playerHp, enemyHp e playerEnergy do BattleUIController.

## Botões e OnClick
O AttackButton deve estar ligado ao BattleUIController. O script registra Button.onClick automaticamente. Não são necessários eventos ou plugins externos.

## Canvas
Use Canvas Scaler -> Scale With Screen Size, Reference Resolution 1080 x 1920 e Match 0.5. Screen Space - Overlay é adequado para o HUD.

## Prefabs
Elementos repetidos recomendados: Combatant, SkillButton, ItemSlot, DialogueOption e StatusBar. A lógica de dados/sistemas já está em C#; a composição visual é feita no Inspector.

## Referências do Inspector
Battle: CombatManager.playerData, CombatManager.enemyData, CombatManager.turns; BattleUIController.combat, retratos, nomes, barras, log e AttackButton.
Narrative: DialogueManager.data; DialogueUIController.manager, labels, Next e opções.

## Objetos necessários
- Bootstrap: GameManager.
- MainMenu: Canvas + botões Novo Jogo/Continuar/Sair.
- WorldMap: mapa + pontos de região.
- Exploration: background + portraits + dialogue + ações.
- Narrative: DialogueManager + Canvas de diálogo.
- Battle: CombatManager + TurnSystem + Canvas/HUD + BattleUIController.

## ScriptableObjects preparados
Player_Caipora.asset, Enemy_Curupira.asset, Skill_Investida.asset e Skill_Ehuita.asset.

## Limitação real da migração
A composição visual das cenas Godot não pode ser convertida 1:1 para Unity porque Nodes/Control/Theme/PackedScene não têm representação binária/textual equivalente. A lógica foi reimplementada em C# e o restante é montagem de cena/Inspector. Nenhuma API, namespace ou dependência externa foi inventada.
