# Arte / assets

Onde colocar cada imagem para que o jogo a use sozinha.

## Cenário da batalha (o fundo da floresta)

1. Coloque a imagem em `assets/backgrounds/`
2. Abra `scenes/battle/battle.tscn`
3. Selecione o nó **`ScenePlaceholder`** (dentro de `StageArea > SceneFrame`)
4. No Inspector, em **Stage Texture Path**, digite o caminho:
   `res://assets/backgrounds/battle_forest.png`
5. Ajuste **Fit**:
   - `KEEP_ASPECT_COVERED` — preenche cortando o excedente (padrão, não deforma)
   - `KEEP_ASPECT` — encaixa a imagem inteira, deixando bordas
   - `STRETCH` — deforma até preencher
6. **Dim Amount** (0 a 1) escurece a imagem para o texto da UI ficar legível.
   Comece em `0.35` se a imagem for muito clara.

Com o campo vazio, a tela desenha um cenário provisório (troncos, folhagem,
fogueira e as silhuetas dos personagens), então dá para validar o layout antes
de a arte existir.

## Fundo do menu e do mapa

`scenes/menu/main_menu.tscn` e `scenes/world/world_map.tscn` têm um nó
**`Backdrop`**. Selecione e preencha **Texture Path** com
`res://assets/backgrounds/nome.png`. **Dim Amount** escurece o fundo.
Vazio = cor sólida, como estava antes.

## Personagens

| O quê | Caminho sugerido | Onde é usado |
|---|---|---|
| Corpo do herói | `assets/characters/caipora_body.png` | `battle.tscn`, nó `HeroBody` |
| Corpo do inimigo | `assets/enemies/curupira_body.png` | `battle.tscn`, nó `EnemyBody` |
| Retrato do herói | `assets/characters/caipora_portrait.png` | `BattleSkills.player()` |
| Retrato do Curupira | `assets/enemies/curupira_portrait.png` | `BattleSkills.enemy()` |

Os retratos e corpos são resolvidos por caminho em
`scripts/battle/battle_skills.gd`. Se o arquivo não existir, a UI cai
automaticamente no placeholder desenhado — nada quebra.

## Ícones

Habilidades, itens equipados e efeitos de status aceitam `icon_path`, também em
`scripts/battle/battle_skills.gd`. Sem arquivo, o slot mostra só a moldura.

## Tamanho recomendado

O viewport do jogo é **1080 x 1920** (retrato). Para fundos que não devem ser
cortados, use **1080 x 1920**. O painel do cenário da batalha ocupa
1080 x 372, então uma imagem de 1080 x 372 entra sem corte com
`KEEP_ASPECT_COVERED`.

## Depois de adicionar

Deixe o Godot importar o arquivo (ele cria o `.import` sozinho) e pressione F5.
Se a imagem não aparecer, confira se o caminho começa com `res://` e o nome do
arquivo está exatamente igual, incluindo a extensão.