extends Node2D

@export var academia: String
@export var total_reps: int = 6
var sequence_length: int = 3
@export var time_limit: float = 3.0
@export var regression_interval: float = 0.2
@export var success_pause: float = 0.5

@onready var sequence_label := $SequenceLabel
@onready var rep_label := $RepLabel
@onready var timeout_timer := $TimeoutTimer
@onready var gian := $gian

var current_reps: int = 0
var current_sequence: Array = []
var player_input: Array = []
var possible_keys = ["A", "S", "D", "F", "J", "K", "L"]

var current_frame: int = 0
var regressing: bool = false
var accepting_input: bool = false   # controla se o jogador pode digitar

func _ready():
	randomize()
	accepting_input = true
	_carregar_skin(GameState.skin)  # ← carrega textura de acordo com a skin salva
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

	current_frame = 0
	_update_sprite_frame()

	timeout_timer.start()
	accepting_input = true


func _unhandled_input(event):
	if regressing or not accepting_input:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var key_str = OS.get_keycode_string(event.keycode).to_upper()
		if key_str in possible_keys:
			player_input.append(key_str)
			check_sequence()


func check_sequence():
	if player_input.size() == 0:
		return

	var index = player_input.size() - 1
	if index >= current_sequence.size():
		return

	if player_input[index] != current_sequence[index]:
		if not timeout_timer.is_stopped():
			timeout_timer.stop()
		accepting_input = false
		start_regression()
		return

	current_frame = min(player_input.size(), 3)
	_update_sprite_frame()

	var display_sequence = []
	for i in range(current_sequence.size()):
		if i < player_input.size():
			display_sequence.append("_")
		else:
			display_sequence.append(current_sequence[i])
	sequence_label.text = " ".join(display_sequence)

	if player_input.size() == current_sequence.size():
		if not timeout_timer.is_stopped():
			timeout_timer.stop()

		accepting_input = false
		current_reps += 1
		rep_label.text = "%d / %d" % [current_reps, total_reps]

		if current_reps >= total_reps:
			await atualizar_minigame2_no_banco()
			TelaCarregamento.show_and_load(academia)
		else:
			await get_tree().create_timer(success_pause).timeout
			start_regression()


func _on_time_up():
	accepting_input = false
	start_regression()


func start_regression():
	if regressing:
		return
	regressing = true
	await _regress_frames()
	regressing = false

	if current_reps < total_reps:
		generate_sequence()


func _regress_frames():
	while current_frame > 0:
		current_frame -= 1
		_update_sprite_frame()
		await get_tree().create_timer(regression_interval).timeout

	current_frame = 0
	_update_sprite_frame()


func _update_sprite_frame():
	if is_instance_valid(gian):
		current_frame = clamp(current_frame, 0, 3)
		gian.frame = current_frame


# --- Atualiza o progresso do minigame2 no banco ---
func atualizar_minigame2_no_banco() -> void:
	if not GameState.user_id:
		push_error("Usuário não logado, não foi possível salvar progresso.")
		return

	GameState.minigame2_completado = true

	var url = "%s/rest/v1/progress?user_id=eq.%s" % [GameState.SUPABASE_URL, GameState.user_id]
	var body = {
		"minigame2_completado": true
	}
	var headers = GameState.get_headers()
	headers.append("Prefer: return=representation")

	var req = HTTPRequest.new()
	add_child(req)
	req.request(url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(body))
	var result = await req.request_completed
	req.queue_free()

	if result[0] == OK:
		print("✅ minigame2_completado atualizado com sucesso para o usuário:", GameState.user_id)
	else:
		push_warning("⚠ Falha ao atualizar minigame2_completado no banco.")


# --- Função para definir a textura conforme a skin escolhida ---
func _carregar_skin(skin_id: int):
	if not is_instance_valid(gian):
		return

	match skin_id:
		1:
			gian.texture = preload("res://assets/characters/demian/demian-triceps.png")
		2:
			gian.texture = preload("res://assets/characters/tim/tim-triceps.png")
		3:
			gian.texture = preload("res://assets/characters/gian/gian-triceps.png")
		4:
			gian.texture = preload("res://assets/characters/isabella/isabella-triceps.png")
		_:
			print("⚠ Skin ID inválido, carregando padrão (gian).")
			gian.texture = preload("res://assets/characters/gian/gian-triceps.png")
