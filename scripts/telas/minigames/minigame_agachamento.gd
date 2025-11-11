extends Node2D

@export var academia: String
@export var total_reps: int = 6
@export var margem_erro: float = 0.05
@export var carga_velocidade: float = 0.4
@export var regressao_velocidade: float = 1.0  # unidades por segundo

@onready var barra := $ProgressBar
@onready var alvo := $ProgressBar/Alvo
@onready var sprite := $gian
@onready var rep_label := $RepLabel

var current_reps := 0
var progresso := 0.0          # 0..1 (percentual)
var alvo_min := 0.0
var alvo_max := 0.0
var carregando := false
var regredindo := false
var tempo_carregando := 0.0

func _ready():
	_carregar_skin(GameState.skin)  # ← carrega a skin do jogador
	randomize()
	barra.value = 0
	rep_label.text = "%d / %d" % [current_reps, total_reps]
	gerar_novo_alvo()
	atualizar_alvo_posicao()


func _process(delta):
	if carregando:
		tempo_carregando += delta
		progresso = clamp(progresso + delta * carga_velocidade, 0.0, 1.0)
		barra.value = progresso * barra.max_value

		if tempo_carregando <= 0.5:
			_set_sprite_frame(1)
		else:
			_set_sprite_frame(2)

	elif regredindo:
		carregando = false
		progresso = max(progresso - regressao_velocidade * delta, 0.0)
		barra.value = progresso * barra.max_value

		if progresso > 0.66:
			_set_sprite_frame(2)
		elif progresso > 0.33:
			_set_sprite_frame(1)
		else:
			_set_sprite_frame(0)

		if progresso <= 0.01:
			progresso = 0.0
			barra.value = 0
			regredindo = false
			_set_sprite_frame(0)
			gerar_novo_alvo()
			atualizar_alvo_posicao()


func _unhandled_input(event):
	if event is InputEventKey and event.keycode == KEY_SPACE:
		if event.pressed and not event.echo:
			iniciar_carregamento()
		elif not event.pressed:
			finalizar_carregamento()


func iniciar_carregamento():
	if regredindo:
		return
	carregando = true
	tempo_carregando = 0.0
	_set_sprite_frame(1)


func finalizar_carregamento():
	if not carregando:
		return
	carregando = false

	if progresso >= alvo_min and progresso <= alvo_max:
		current_reps += 1
		rep_label.text = "%d / %d" % [current_reps, total_reps]
		print("✅ Acertou! Reps:", current_reps)
		_set_sprite_frame(2)

		if current_reps >= total_reps:
			await atualizar_minigame1_no_banco()
			TelaCarregamento.show_and_load(academia)
			return
	else:
		print("❌ Errou. Recomeçando...")
		_set_sprite_frame(3)

	await get_tree().create_timer(0.7).timeout
	regredindo = true


func gerar_novo_alvo():
	var centro_percent = randf_range(0.2, 0.8)
	alvo_min = centro_percent - margem_erro
	alvo_max = centro_percent + margem_erro


func atualizar_alvo_posicao():
	var altura_barra = barra.size.y
	var largura_barra = barra.size.x
	var altura_alvo = (alvo_max - alvo_min) * altura_barra
	var centro_percent = (alvo_min + alvo_max) * 0.5
	var centro_px = (1.0 - centro_percent) * altura_barra

	alvo.custom_minimum_size = Vector2(largura_barra, altura_alvo)
	alvo.position = Vector2(0, centro_px - altura_alvo * 0.5)


func _set_sprite_frame(f: int):
	if is_instance_valid(sprite):
		sprite.frame = clamp(f, 0, 3)


# --- Atualiza o progresso do minigame3 no banco ---
func atualizar_minigame1_no_banco() -> void:
	if not GameState.user_id:
		push_error("Usuário não logado, não foi possível salvar progresso.")
		return

	GameState.minigame1_completado = true

	var url = "%s/rest/v1/progress?user_id=eq.%s" % [GameState.SUPABASE_URL, GameState.user_id]
	var body = { "minigame1_completado": true }
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
		push_warning("⚠ Falha ao atualizar minigame3_completado no banco.")


# --- Define a textura conforme a skin salva ---
func _carregar_skin(skin_id: int):
	if not is_instance_valid(sprite):
		return

	match skin_id:
		1:
			sprite.texture = preload("res://assets/characters/demian/demian-agachamento.png")
		2:
			sprite.texture = preload("res://assets/characters/tim/tim-agachamento.png")
		3:
			sprite.texture = preload("res://assets/characters/gian/gian-agachamento.png")
		4:
			sprite.texture = preload("res://assets/characters/isabella/isabella-agachamento.png")
		_:
			print("⚠ Skin ID inválido, carregando padrão (gian).")
			sprite.texture = preload("res://assets/characters/gian/gian-agachamento.png")
