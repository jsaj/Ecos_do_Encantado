# 🚀 Setup - Ecos do Encantado

## Pré-requisitos

- **Godot 4.x** (Download: https://godotengine.org)
- **Git** (para versionamento)

## Instalação

### 1. Clonar o Repositório

```bash
git clone <seu-repositório-url> Ecos_do_Encantado
cd Ecos_do_Encantado
```

### 2. Abrir no Godot

1. Abra o editor Godot 4.x
2. Clique em **"Abrir Projeto"**
3. Navegue até a pasta `Ecos_do_Encantado`
4. Abra o arquivo `project.godot`

### 3. Executar

Pressione **F5** ou clique em **"Executar"** para iniciar o jogo.

## Estrutura do Projeto

```
Ecos_do_Encantado/
├── assets/              # Imagens, sons, backgrounds
├── data/                # Dados em JSON/Resources
├── scenes/              # Cenas do Godot
├── scripts/             # Código GDScript
├── resources/           # Resources do Godot
├── autoload/            # AutoLoads globais
├── tests/               # Testes
├── project.godot        # Configuração do projeto
├── main.tscn            # Cena principal
├── README.md            # Documentação
└── SETUP.md             # Este arquivo
```

## Autoloads

O projeto utiliza os seguintes AutoLoads (acessíveis globalmente):

- **GameManager**: Gerencia o estado geral do jogo
- **SceneManager**: Gerencia carregamento de cenas
- **GameState**: Armazena dados do jogador e mundo

## Fluxo de Execução

```
Boot (main.tscn)
    ↓
Menu Principal
    ↓
Novo Jogo → Mapa do Mundo
```

## Troubleshooting

### Erro: "Script não encontrado"

- Verifique se todos os arquivos estão nas pastas corretas
- Recarregue o projeto em Godot (Arquivo → Recarregar)

### Erro: "Autoload não definido"

- Vá para Projeto → Configurações do Projeto → Autoload
- Verifique se `GameManager`, `SceneManager` e `GameState` estão listados

### Cena não carrega

- Verifique os paths nos scripts
- Certifique-se de que o arquivo `.tscn` existe no caminho especificado

## Desenvolvimento

### Adicionar Novo Script

1. Crie o arquivo `.gd` na pasta apropriada em `scripts/`
2. Se for um AutoLoad global, configure em Projeto → Configurações

### Adicionar Nova Cena

1. Crie a cena em `.tscn` na pasta apropriada em `scenes/`
2. Atualize as constantes em `scripts/core/constants.gd` se necessário
3. Use `SceneManager.load_scene()` para carregá-la

## Commits e Versionamento

Cada fase de desenvolvimento terá um commit com histórico claro:

```bash
git log --oneline
```

Para contribuir:

```bash
git checkout -b feature/nova-funcionalidade
# Faça mudanças...
git add .
git commit -m "Descrição clara das mudanças"
git push origin feature/nova-funcionalidade
```

## Contato e Dúvidas

Para dúvidas sobre o desenvolvimento, consulte o arquivo `README.md`.

---

**Bom desenvolvimento! 🎮**
