# Ecos do Encantado — Unity Migration

Migração executada a partir da implementação Godot existente.

Arquitetura: Unity nativo + C# + ScriptableObjects + MonoBehaviours + uGUI. Não há namespaces próprios, plugins ou frameworks externos.

Fluxo: Bootstrap -> MainMenu -> WorldMap -> Exploration/Narrative -> Battle.

O script EcosProjectSetup.cs cria pastas, dados e cenas auxiliares pelo menu Ecos do Encantado > Setup Project.
