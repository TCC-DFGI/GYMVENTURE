extends CanvasLayer

@export var imagem_path: String   # Caminho da imagem de instrução
@export var texto_instrucao: String
@export var tecla: String

@onready var imagem := $FundoBotão
@onready var label := $Label
@onready var botao := $Botão

func _ready():
	# Define imagem e texto automaticamente
	if imagem_path != "":
		imagem.texture = load(imagem_path)
	label.text = texto_instrucao
	botao.text = tecla
	
	
	# Mostra o tutorial e trava o jogador
	visible = true
	self.layer = 100
	
	var player = _get_player()
	if player:
		player.set_pode_mover(false)

func _unhandled_input(event):
	# Ignora todos os inputs exceto espaço
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER:
			_close_and_restore_player()
			return
		else:
			get_viewport().set_input_as_handled() # bloqueia outras teclas

func _close_and_restore_player() -> void:
	queue_free() # remove totalmente o CanvasLayer
	var player = _get_player()
	if player:
		player.set_pode_mover(true)


func _get_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null
