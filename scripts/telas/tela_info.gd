extends CanvasLayer

@onready var imagem_node: Node = $Imagem
@onready var texto: Label = $Texto
@onready var titulo: Label = $Titulo
@onready var voltar_btn: Button = $VoltarBtn
@onready var iniciar_btn: Button = $IniciarBtn

var minigame_url: String = ""

func _ready():
	voltar_btn.pressed.connect(_on_voltar_pressed)
	iniciar_btn.pressed.connect(_on_iniciar_pressed)
	visible = false

func mostrar_info(nome: String, descricao: String, textura_exercicio: Texture2D, minigame: String) -> void:
	if titulo:
		titulo.text = nome
	if texto:
		texto.text = descricao

	if textura_exercicio != null:
		imagem_node.texture = textura_exercicio
	minigame_url = minigame
	visible = true
	self.layer = 100

	# trava o player
	var player = _get_player()
	if player:
		player.set_pode_mover(false)

func _on_voltar_pressed() -> void:
	_close_and_restore_player()

func _on_iniciar_pressed() -> void:
	if minigame_url == "" or minigame_url == null:
		push_error("Nenhum minigame definido!")
		return

	# salva progresso
	await GameState.salvar_progresso_global()

	_close_and_restore_player()
	TelaCarregamento.show_and_load(minigame_url)

func _close_and_restore_player() -> void:
	visible = false
	var player = _get_player()
	if player:
		player.set_pode_mover(true)

func _get_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null
