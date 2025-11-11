extends Node2D

@export var academia: String

@export var total_reps: int = 6
@export var margem_erro: float = 0.05
@export var carga_aceleracao: float = 0.8
@export var regressao_velocidade: float = 0.4
@export var progresso_velocidade: float = 0.6
@export var regredindo_total_vel: float = 1.2
@export var alvo_velocidade_base: float = 0.4
@export var alvo_variacao: float = 1.5

@onready var barra := $ProgressBar
@onready var progresso_barra := $Progresso
@onready var alvo := $ProgressBar/Alvo
@onready var sprite := $gian
@onready var rep_label := $RepLabel

var progresso := 0.0
var progresso_reps := 0.0
var carregando := false
var regredindo_total := false
var alvo_pos := 0.5
var alvo_direcao := 1.0
var alvo_velocidade := 0.4
var tempo_aleatorio := 0.0
var current_reps := 0

func _ready():
	await _carregar_skin(GameState.skin)
	randomize()
	barra.value = 0
	progresso_barra.value = 0
	rep_label.text = "%d / %d" % [current_reps, total_reps]
	gerar_novo_alvo()

func _process(delta):
	atualizar_alvo(delta)
	atualizar_barra_instavel(delta)
	atualizar_progresso(delta)
	atualizar_sprite_por_progresso()

func atualizar_barra_instavel(delta):
	if carregando:
		progresso += carga_aceleracao * delta
	else:
		progresso -= regressao_velocidade * delta
	progresso = clamp(progresso, 0.0, 1.0)
	barra.value = progresso * barra.max_value

func atualizar_progresso(delta):
	if regredindo_total:
		progresso_reps -= regredindo_total_vel * delta
		if progresso_reps <= 0:
			progresso_reps = 0.0
			regredindo_total = false
		progresso_barra.value = progresso_reps * progresso_barra.max_value
		return

	if abs(progresso - alvo_pos) <= margem_erro:
		progresso_reps += progresso_velocidade * delta
		progresso_reps = clamp(progresso_reps, 0.0, 1.0)
		progresso_barra.value = progresso_reps * progresso_barra.max_value

		if progresso_reps >= 1.0:
			current_reps += 1
			if current_reps >= total_reps:
				await atualizar_minigame2_no_banco()
				TelaCarregamento.show_and_load(academia)
				return
			rep_label.text = "%d / %d" % [current_reps, total_reps]
			print("✅ Repetição completa!", current_reps)

			regredindo_total = true
			progresso_reps = 1.0
			progresso_barra.value = progresso_reps * progresso_barra.max_value

func atualizar_alvo(delta):
	if not is_instance_valid(alvo):
		return

	tempo_aleatorio -= delta
	if tempo_aleatorio <= 0:
		alvo_direcao = randf_range(-1.0, 1.0)
		alvo_velocidade = alvo_velocidade_base + randf_range(0.0, alvo_variacao)
		tempo_aleatorio = randf_range(0.3, 0.8)

	alvo_pos += alvo_direcao * alvo_velocidade * delta

	var altura_barra = barra.size.y
	var altura_alvo = alvo.size.y
	var pos_min = (altura_alvo/2) / altura_barra
	var pos_max = 1 - (altura_alvo/2) / altura_barra
	alvo_pos = clamp(alvo_pos, pos_min, pos_max)

	alvo.position.y = altura_barra - altura_alvo - (alvo_pos * (altura_barra - altura_alvo))

func _unhandled_input(event):
	if regredindo_total:
		return
	if event.is_action_pressed("ui_accept"):
		carregando = true
	elif event.is_action_released("ui_accept"):
		carregando = false

func atualizar_sprite_por_progresso():
	if not is_instance_valid(sprite):
		return
	var pct = progresso_reps
	if pct < 0.25:
		sprite.frame = 0
	elif pct < 0.5:
		sprite.frame = 1
	elif pct < 0.75:
		sprite.frame = 2
	else:
		sprite.frame = 3

func gerar_novo_alvo():
	alvo_pos = randf_range(0.2, 0.8)

# ===============================
# BANCO DE DADOS (minigame2)
# ===============================
func atualizar_minigame2_no_banco() -> void:
	if not GameState.user_id:
		push_error("Usuário não logado, não foi possível salvar progresso.")
		return

	GameState.minigame2_completado = true

	var url = "%s/rest/v1/progress?user_id=eq.%s" % [GameState.SUPABASE_URL, GameState.user_id]
	var body = { "minigame2_completado": true }
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

func _carregar_skin(skin_id: int):
	if not is_instance_valid(sprite):
		print("invállido")
		return

	match skin_id:
		1:
			sprite.texture = preload("res://assets/characters/demian/demian-panturrilha.png")
		2:
			sprite.texture = preload("res://assets/characters/tim/tim-panturrilha.png")
		3:
			sprite.texture = preload("res://assets/characters/gian/gian-panturrilha.png")
		4:
			sprite.texture = preload("res://assets/characters/isabella/isabella-panturrilha.png")
		_:
			print("⚠ Skin ID inválido, carregando padrão (gian).")
			sprite.texture = preload("res://assets/characters/gian/gian-panturrilha.png")
