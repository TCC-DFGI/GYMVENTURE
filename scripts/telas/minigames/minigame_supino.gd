extends Node2D

@export var academia: String 
@export var total_reps: int = 10 # Quantas repetições no total

var press_amount: int = 100 # Quantos pontos precisa pra uma rep

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var rep_label: Label = $RepLabel
@onready var personagem: Sprite2D = $gian

var current_reps: int = 0
var current_press_amount: float = 0
var finished: bool = false
var current_frame: int = 0

func _ready():
	_carregar_skin(GameState.skin)  # ← carrega a skin correspondente
	progress_bar.value = 0
	rep_label.text = "%d / %d" % [current_reps, total_reps]


func _process(delta):
	if finished:
		return

	# Animações simples baseadas na força atual
	if current_press_amount > 75:
		current_frame = 3
	elif current_press_amount > 40:
		current_frame = 2
	elif current_press_amount > 20:
		current_frame = 1
	else:
		current_frame = 0
	personagem.frame = current_frame

	# Apertou a tecla de ação
	if Input.is_action_just_pressed("ui_accept") and current_reps < total_reps:
		if current_press_amount > 80:
			current_press_amount += 15
		elif current_press_amount > 50:
			current_press_amount += 18
		elif current_press_amount > 0:
			current_press_amount += 20
		else:
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
				rep_label.text = "%d / %d" % [current_reps, total_reps]
				await atualizar_minigame1_no_banco()
				TelaCarregamento.show_and_load(academia)
	elif current_press_amount > 0:
		current_press_amount -= 0.5
		progress_bar.value = current_press_amount
	else:
		progress_bar.value = 0


# --- Atualiza o progresso no banco ---
func atualizar_minigame1_no_banco() -> void:
	if not GameState.user_id:
		push_error("Usuário não logado, não foi possível salvar progresso.")
		return

	GameState.minigame1_completado = true

	var url = "%s/rest/v1/progress?user_id=eq.%s" % [GameState.SUPABASE_URL, GameState.user_id]
	var body = {
		"minigame1_completado": true
	}
	var headers = GameState.get_headers()
	headers.append("Prefer: return=representation")

	var req = HTTPRequest.new()
	add_child(req)
	req.request(url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(body))
	var result = await req.request_completed
	req.queue_free()

	if result[0] == OK:
		print("✅ minigame1_completado atualizado com sucesso para o usuário:", GameState.user_id)
	else:
		push_warning("⚠ Falha ao atualizar minigame1_completado no banco.")


# --- Define a textura conforme a skin salva ---
func _carregar_skin(skin_id: int):
	if not is_instance_valid(personagem):
		return

	match skin_id:
		1:
			personagem.texture = preload("res://assets/characters/demian/demian-supino.png")
		2:
			personagem.texture = preload("res://assets/characters/tim/tim-supino.png")
		3:
			personagem.texture = preload("res://assets/characters/gian/gian-supino.png")
		4:
			personagem.texture = preload("res://assets/characters/isabella/isabella-supino.png")
		_:
			print("⚠ Skin ID inválido, carregando padrão (gian).")
			personagem.texture = preload("res://assets/characters/gian/gian-supino.png")
