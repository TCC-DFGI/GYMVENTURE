extends Node

# Dicionário para armazenar quais exercícios foram concluídos
var equipamentos_concluidos: Dictionary = {}

func concluir_exercicio(nome: String):
	equipamentos_concluidos[nome] = true

func foi_concluido(nome: String) -> bool:
	return equipamentos_concluidos.get(nome, false)
