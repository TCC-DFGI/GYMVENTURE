extends CanvasLayer

@onready var panel = $Panel
@onready var img = $Panel/HBoxContainer/TextureRect
@onready var texto = $Panel/HBoxContainer/VBoxContainer/Label
@onready var botao = $Panel/HBoxContainer/VBoxContainer/Button

var cena_minigame: PackedScene = null
var equipamento_ref = null

func _ready():
	visible = false
	botao.pressed.connect(_on_iniciar_pressed)

# mostrar recebe a cena do minigame e também referência do equipamento que chamou (para marcar depois)
func mostrar(imagem: Texture, descricao: String, minigame: PackedScene, equipamento=null):
	img.texture = imagem
	texto.text = descricao
	cena_minigame = minigame
	equipamento_ref = equipamento
	visible = true
	# opcional: pausar o jogo? get_tree().paused = true

func esconder():
	visible = false
	# get_tree().paused = false

func _on_iniciar_pressed():
	visible = false
	# trocar pra cena do minigame; o minigame, quando concluído, deve chamar GameState.mark_completed(equipamento_ref.nome)
	if cena_minigame:
		get_tree().change_scene_to_packed(cena_minigame)
