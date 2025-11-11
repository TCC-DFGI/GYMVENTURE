extends CanvasLayer

@export var destino: String = "res://telas/menu.tscn"

@onready var musica_btn: Button = $MusicaBtn
@onready var som_btn: Button = $SomBtn
@onready var sair_btn: Button = $SairBtn
@onready var voltar_btn: Button = $VoltarBtn

var ativo := false

func _ready():
	visible = false
	sair_btn.pressed.connect(_on_sair_pressed)
	voltar_btn.pressed.connect(_on_voltar_pressed)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"): # ESC padrão
		if not ativo:
			abrir_pause()
		else:
			fechar_pause()

func abrir_pause():
	ativo = true
	visible = true
	self.layer = 100

	var player = _get_player()
	if player:
		player.set_pode_mover(false)

func fechar_pause():
	ativo = false
	visible = false

	var player = _get_player()
	if player:
		player.set_pode_mover(true)

func _on_sair_pressed():
	visible = false
	print("⬅ Voltando para o menu:", destino)
	TelaCarregamento.show_and_load(destino)

func _on_voltar_pressed():
	fechar_pause()

func _get_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null
