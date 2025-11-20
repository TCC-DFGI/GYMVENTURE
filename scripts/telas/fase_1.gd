extends Node2D

@onready var dialogo = $Diálogo

func _ready():
	var player = _get_player()
	if player:
		player.set_pode_mover(false)

	# Verifica se o minigame já foi feito
	var tipo = GameState.fase_atual
	if _minigame_ja_completado():
		tipo = 4

	# Só mostra o diálogo se ainda não tiver sido exibido antes
	if not GameState.dialogo_fase_mostrado:
		await dialogo.iniciar_dialogo(tipo)
		GameState.dialogo_fase_mostrado = true
	else:
		# Já foi mostrado — libera o movimento imediatamente
		if player:
			player.set_pode_mover(true)


func _get_player():
	return $player


func _minigame_ja_completado() -> bool:
	return GameState.minigame1_completado or GameState.minigame2_completado
