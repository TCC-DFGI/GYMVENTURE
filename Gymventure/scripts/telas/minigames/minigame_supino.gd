extends Node2D

@export var academia: String 
@export var total_reps: int = 10 # Quantas repetições no total

var press_amount: int = 100 # Quantos pontos precisa pra uma rep

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var rep_label: Label = $RepLabel
@onready var personagem: Sprite2D = $gian

var current_reps: int = 0 #Quantas reps já fez
var current_press_amount: int #Quantos pontos já fez
var finished: bool = false #Se terminou o minigame
var current_frame: int = 0

func _ready():
	# Configurar a barra de progresso
	progress_bar.value = 0

	# Mostrar contador inicial
	rep_label.text = "%d / %d" % [current_reps, total_reps]
	
func _process(delta):
	if finished:
		return

	if current_press_amount>75:
		current_frame = 3
	elif current_press_amount>40:
		current_frame = 2
	elif current_press_amount>20:
		current_frame = 1
	elif current_press_amount == 0:
		current_frame = 0
	$gian.frame = current_frame
	# Apertou a tecla de ação
	if Input.is_action_just_pressed("ui_accept") and current_reps < total_reps:
		if current_press_amount>80:
			current_press_amount += 15
		elif current_press_amount>50:
			current_press_amount += 18
		elif current_press_amount>0:
			current_press_amount += 20
		elif current_press_amount == 0:
			current_press_amount += 25
		progress_bar.value = current_press_amount
		

		# Se completou a repetição
		if current_press_amount >= press_amount:
			current_press_amount = 0
			current_reps += 1
			rep_label.text = "%d / %d" % [current_reps, total_reps]

			# Se completou todas as repetições
		if current_reps >= total_reps:
			finished = true
			rep_label.text = "✅ %d / %d" % [current_reps, total_reps]
			TelaCarregamento.show_and_load(academia)
	elif current_press_amount > 0:
		current_press_amount -= 0.5
		progress_bar.value = current_press_amount
	else:
		progress_bar.value = 0
