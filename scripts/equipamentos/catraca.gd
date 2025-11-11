extends Node2D

@export var tecla_interacao := "E"
@export var tempo_aberta := 2.0  # tempo em segundos que a catraca fica aberta

@onready var area := $Area2D
@onready var colisao := $StaticBody2D/Catraca
@onready var exclamacao := $exclamação
@onready var sprite := $Sprite2D  # sprite da catraca (com 2 frames: 0 = fechada, 1 = aberta)

var jogador_proximo := false
var catraca_aberta := false

func _ready():
	exclamacao.visible = false
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	_atualizar_estado_catraca()

func _on_body_entered(body):
	if body.is_in_group("player"):
		jogador_proximo = true
		exclamacao.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		jogador_proximo = false
		exclamacao.visible = false

func _process(delta):
	if jogador_proximo and Input.is_action_just_pressed("interact"):
		if not catraca_aberta:
			_abrir_catraca()
		else:
			print("⏳ A catraca já está aberta!")

func _abrir_catraca():
	catraca_aberta = true
	colisao.disabled = true
	exclamacao.visible = false
	sprite.frame = 1  # frame de catraca aberta
	print("🚪 Catraca aberta, jogador pode passar!")

	# Cria um timer temporário de 2 segundos (não precisa de nó nem variável)
	await get_tree().create_timer(tempo_aberta).timeout
	_fechar_catraca()

func _fechar_catraca():
	catraca_aberta = false
	colisao.disabled = false
	sprite.frame = 0  # volta ao frame de catraca fechada
	print("🔒 Catraca fechou automaticamente.")
	if jogador_proximo:
		exclamacao.visible = true

func _atualizar_estado_catraca():
	if catraca_aberta:
		colisao.disabled = true
		sprite.frame = 1
	else:
		colisao.disabled = false
		sprite.frame = 0
