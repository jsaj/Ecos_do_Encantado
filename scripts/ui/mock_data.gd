class_name MockData
extends Node

## Dados mock para testes da arquitetura Dumb Terminal

static func battle_state() -> Dictionary:
	"""Retorna um estado completo de batalha para testes"""
	return {
		"background": {
			"image_path": "res://assets/backgrounds/forest.webp"
		},
		
		"characters": {
			"player": {
				"name": "Herói da Floresta",
				"image_path": "res://assets/characters/player.webp"
			},
			"enemy": {
				"name": "Curupira",
				"image_path": "res://assets/characters/curupira.webp"
			}
		},
		
		"status": {
			"hp": 75,
			"max_hp": 100,
			"mp": 20,
			"max_mp": 30,
			"stamina": 12,
			"max_stamina": 20
		},
		
		"information": {
			"mapa": [
				"Localização: Floresta Amazônica - Profundeza",
				"Terreno: Úmido e denso",
				"Próximo Objetivo: Encontrar o Curupira para obter informações"
			],
			
			"atributos": [
				"💪 Força: 12",
				"🎯 Destreza: 15",
				"🧠 Inteligência: 10",
				"🛡️ Constituição: 14",
				"✨ Sabedoria: 13"
			],
			
			"missoes": [
				"[] Entregar a oferenda à Iara no Rio",
				"[X] Escapar da caverna do Boto",
				"[] Buscar ervas na Mata Atlântica",
				"[] Encontrar o Curupira"
			],
			
			"dicas": [
				"💡 O Curupira é vulnerável a magia de água",
				"💡 Evite ataques com fogo - aumenta a raiva do Curupira",
				"💡 Use técnicas defensivas contra ataques rápidos",
				"💡 Você pode usar a Oferenda da Iara como item especial"
			]
		},
		
		"actions": [
			{
				"label": "Atacar",
				"accent_color": Color(0.8, 0.2, 0.2, 1),  # Vermelho
				"icon_path": "res://assets/icons/sword.png",
				"action_id": "attack"
			},
			{
				"label": "Magia",
				"accent_color": Color(0.2, 0.6, 0.9, 1),  # Azul
				"icon_path": "res://assets/icons/magic.png",
				"action_id": "magic"
			},
			{
				"label": "Defender",
				"accent_color": Color(0.5, 0.7, 0.3, 1),  # Verde
				"icon_path": "res://assets/icons/shield.png",
				"action_id": "defend"
			},
			{
				"label": "Item",
				"accent_color": Color(0.8, 0.7, 0.2, 1),  # Amarelo
				"icon_path": "res://assets/icons/potion.png",
				"action_id": "item"
			}
		]
	}


static func exploration_state() -> Dictionary:
	"""Retorna um estado de exploração"""
	return {
		"background": {
			"image_path": "res://assets/backgrounds/forest_path.webp"
		},
		
		"characters": {
			"player": {
				"name": "Explorador",
				"image_path": "res://assets/characters/explorer.webp"
			},
			"enemy": {
				"name": "",
				"image_path": ""
			}
		},
		
		"status": {
			"hp": 95,
			"max_hp": 100,
			"mp": 28,
			"max_mp": 30,
			"stamina": 18,
			"max_stamina": 20
		},
		
		"information": {
			"mapa": [
				"Você está caminhando por um caminho de floresta",
				"Você vê uma trilha para esquerda",
				"À direita, sons de água correndo"
			],
			
			"atributos": [
				"💪 Força: 12",
				"🎯 Destreza: 15",
				"🧠 Inteligência: 10",
				"🛡️ Constituição: 14",
				"✨ Sabedoria: 13"
			],
			
			"missoes": [
				"[] Explorar a Floresta Amazônica",
				"[] Encontrar 3 cristais perdidos",
				"[X] Conversar com Iara"
			],
			
			"dicas": [
				"Você aprendeu: Magia de Água +5% eficácia",
				"Próximo nível em 150 XP",
				"Melhorias disponíveis no Acampamento"
			]
		},
		
		"actions": [
			{
				"label": "Esquerda",
				"accent_color": Color(0.8, 0.6, 0.2, 1),
				"icon_path": "res://assets/icons/arrow_left.png",
				"action_id": "go_left"
			},
			{
				"label": "Direita",
				"accent_color": Color(0.2, 0.6, 0.8, 1),
				"icon_path": "res://assets/icons/arrow_right.png",
				"action_id": "go_right"
			},
			{
				"label": "Frente",
				"accent_color": Color(0.6, 0.8, 0.2, 1),
				"icon_path": "res://assets/icons/arrow_up.png",
				"action_id": "go_forward"
			},
			{
				"label": "Voltar",
				"accent_color": Color(0.8, 0.2, 0.6, 1),
				"icon_path": "res://assets/icons/arrow_down.png",
				"action_id": "go_back"
			}
		]
	}


static func status_update_example() -> Dictionary:
	"""Exemplo de atualização de status após uma ação"""
	return {
		"hp": 65,
		"max_hp": 100,
		"mp": 15,
		"max_mp": 30,
		"stamina": 8,
		"max_stamina": 20
	}


static func tab_update_examples() -> Dictionary:
	"""Exemplos de atualizações de abas"""
	return {
		InformationLayer.TAB_MAPA: [
			"O Curupira se aproxima...",
			"Você percebe seus olhos brilharem em vermelho"
		],
		
		InformationLayer.TAB_ATRIBUTOS: [
			"💪 Força: 12 (+1 buff temporário)",
			"🎯 Destreza: 15",
			"🧠 Inteligência: 10",
			"🛡️ Constituição: 14",
			"✨ Sabedoria: 13 (+2 magia de água)"
		],
		
		InformationLayer.TAB_MISSOES: [
			"[] Derrotar o Curupira",
			"[X] Escapar da caverna do Boto",
			"[] Buscar ervas na Mata Atlântica"
		],
		
		InformationLayer.TAB_DICAS: [
			"⚠️ O Curupira está ENFURECIDO",
			"💡 Use magia de água no próximo turno",
			"💡 Sua stamina está baixa - considere defender"
		]
	}


## Cenários de teste
static func get_test_scenarios() -> Array[String]:
	return [
		"battle_state",
		"exploration_state",
		"status_update_example",
		"tab_update_examples"
	]


## Função auxiliar para debug
static func print_data_structure(data: Dictionary, indent: int = 0) -> void:
	var prefix = "  ".repeat(indent)
	for key in data.keys():
		var value = data[key]
		if value is Dictionary:
			print(prefix + key + ": {")
			print_data_structure(value, indent + 1)
			print(prefix + "}")
		elif value is Array:
			print(prefix + key + ": [")
			for item in value:
				if item is Dictionary:
					print_data_structure({"item": item}, indent + 1)
				else:
					print(prefix + "  " + str(item))
			print(prefix + "]")
		else:
			print(prefix + key + ": " + str(value))
