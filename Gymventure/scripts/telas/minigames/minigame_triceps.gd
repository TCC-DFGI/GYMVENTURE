extends Node2D

@export var total_reps: int = 1
var sequence_length: int = 3
@export var time_limit: float = 3.0
@export var regression_interval: float = 0.2

@onready var sequence_label := $SequenceLabel
@onready var rep_label := $RepLabel
@onready var timeout_timer := $TimeoutTimer
@onready var gian := $gian  # Sprite2D com hframes configurado

var current_reps: int = 0
var current_sequence: Array = []
var player_input: Array = []
var possible_keys = ["A", "S", "D", "F", "J", "K", "L"]

var current_frame: int = 0
var regressing: bool = false

func _ready():
	randomize()
	# configura o timer que já existe na cena
	timeout_timer.wait_time = time_limit
	timeout_timer.one_shot = true
	if not timeout_timer.is_connected("timeout", Callable(self, "_on_time_up")):
		timeout_timer.timeout.connect(_on_time_up)

	rep_label.text = "%d / %d" % [current_reps, total_reps]
	generate_sequence()
	_update_sprite_frame()

func generate_sequence():
	current_sequence.clear()
	for i in range(sequence_length):
		current_sequence.append(possible_keys[randi() % possible_keys.size()])

	sequence_label.text = " ".join(current_sequence)
	player_input.clear()

	# reset de frame para o início da nova sequência
	current_frame = 0
	_update_sprite_frame()

	# (re)inicia o timeout para a próxima entrada
	timeout_timer.start()

func _unhandled_input(event):
	# bloqueia entrada durante a animação de regressão
	if regressing:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var key_str = OS.get_keycode_string(event.keycode).to_upper()
		if key_str in possible_keys:
			player_input.append(key_str)
			check_sequence()

func check_sequence():
	# segurança: se por algum motivo não houver nada no player_input
	if player_input.size() == 0:
		return

	var index = player_input.size() - 1
	# se errou no último caractere digitado
	if player_input[index] != current_sequence[index]:
		# cancela o timer e inicia regressão
		if not timeout_timer.is_stopped():
			timeout_timer.stop()
		start_regression()
		return

	# se acertou o caractere, avança frame (até 3)
	current_frame = min(player_input.size(), 3)
	_update_sprite_frame()

	# se terminou a sequência inteira
	if player_input.size() == current_sequence.size():
		# parou o timer (já acertou a sequência)
		if not timeout_timer.is_stopped():
			timeout_timer.stop()

		current_reps += 1
		rep_label.text = "%d / %d" % [current_reps, total_reps]

		# se atingiu o total, chama o carregamento
		if current_reps >= total_reps:
			# marque no GameState, se usar
			# GameState.complete_exercise("supino")
			TelaCarregamento.show_and_load("res://telas/academia.tscn")
		else:
			# acertou: faz a regressão visual (1 a 1) e só depois gera nova sequência
			start_regression()

func _on_time_up():
	# tempo esgotou: iniciar regressão
	start_regression()

func start_regression():
	if regressing:
		return
	regressing = true
	# aguarda a rotina de regressão terminar
	await _regress_frames()
	regressing = false

	# só gera nova sequência se ainda não terminou o minigame
	if current_reps < total_reps:
		generate_sequence()

func _regress_frames():
	# desce um frame por vez até chegar em 0, aguardando entre frames
	while current_frame > 0:
		current_frame -= 1
		_update_sprite_frame()
		await get_tree().create_timer(regression_interval).timeout

	# garantir frame 0
	current_frame = 0
	_update_sprite_frame()
	# fim da coroutine

func _update_sprite_frame():
	# atualiza o sprite se existir
	if is_instance_valid(gian):
		# garante que frame fique dentro do intervalo válido
		#var max_frame := max(0, gian.hframes * gian.vframes - 1)
		#current_frame = clamp(current_frame, 0, max_frame)
		gian.frame = current_frame
