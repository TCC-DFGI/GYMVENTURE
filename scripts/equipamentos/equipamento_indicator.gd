extends Node2D

@export var nome_exercicio: String = ""
@export var descricao_exercicio: String = ""
@export var imagem_exercicio: Texture2D  # use Texture2D no Inspector
@export var minigame_caminho: String = ""

@onready var area: Area2D = $Area2D
var player_in_area: bool = false

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	z_index = int(position.y)
	$exclamação.visible = true

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
		if $exclamação:
			$exclamação.visible = false

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		if $exclamação:
			$exclamação.visible = true

func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		abrir_tela_info()

func abrir_tela_info():
	var painel = get_tree().get_first_node_in_group("painel_info")
	if painel:
		# Note: passamos o nome, descrição, a Texture2D e o caminho do minigame
		painel.mostrar_info(
			nome_exercicio,
			descricao_exercicio,
			imagem_exercicio,
			minigame_caminho
		)
	else:
		push_error("⚠️ PainelInfo não encontrado! Coloque o CanvasLayer no grupo 'painel_info'.")
