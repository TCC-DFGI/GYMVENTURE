extends Node2D

@export var minigame: String
@onready var area = $Area2D
var player_in_area = false  # Detecta se o jogador está perto

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"): # Adicione seu Player no grupo "player"
		player_in_area = true
		$estrela.visible = true  # Mostra a estrela

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		$estrela.visible = false

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
	#CARREGA E TROCA PRO MINIGAME
		TelaCarregamento.show_and_load(minigame)
