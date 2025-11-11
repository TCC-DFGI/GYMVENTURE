extends Node2D

@export var academia: String
@export var total_reps: int = 6
@export var margem_erro: float = 0.07
@export var velocidade_base: float = 300.0
@export var aumento_velocidade: float = 30.0
@export var regressao_velocidade: float = 0.2

@onready var barra := $ProgressBar
@onready var alvo := $ProgressBar/Alvo
@onready var pointer := $ProgressBar/Pointer
@onready var rep_label := $RepLabel
@onready var sprite := $gian

var alvo_pos := 0.0
var pointer_pos := 0.0
var pointer_direcao := 1.0
var pointer_velocidade := velocidade_base
var current_reps := 0
var progresso_geral := 0.0
var regredindo := false


func _ready():
	_carregar_skin(GameState.skin)
	randomize()
	rep_label.text = "%d / %d" % [current_reps, total_reps]
	gerar_novo_alvo()


func _process(delta):
	atualizar_pointer(delta)
	atualizar_regressao(delta)


func atualizar_pointer(delta):
	var largura_barra = barra.size.x
	var largura_pointer = pointer.size.x

	# Atualiza posição normalizada
	pointer_pos += pointer_direcao * pointer_velocidade * delta / largura_barra

	# Limites (corrigido para não ultrapassar visualmente o fim)
	var limite_min = 0.0
	var limite_max = 1.0 - (largura_pointer / largura_barra)

	if pointer_pos >= limite_max:
		pointer_pos = limite_max
		pointer_direcao = -1.0
	elif pointer_pos <= limite_min:
		pointer_pos = limite_min
		pointer_direcao = 1.0

	pointer.position.x = pointer_pos * largura_barra


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		if abs(pointer_pos - alvo_pos) <= margem_erro:
			# ✅ Acertou
			current_reps += 1
			rep_label.text = "%d / %d" % [current_reps, total_reps]
			print("✅ Acertou repetição", current_reps)
			await _animar_sprite_acerto()

			# Gera novo alvo
			gerar_novo_alvo()

			# Aumenta velocidade gradualmente
			pointer_velocidade += aumento_velocidade

			# Inicia regressão (simbólica)
			regredindo = true

			# Checa se terminou todas as repetições
			if current_reps >= total_reps:
				print("🏁 Minigame completo! Salvando progresso...")
				await atualizar_minigame1_no_banco()
				TelaCarregamento.show_and_load(academia)
				return

		else:
			# ❌ Errou
			print("❌ Errou!")
			await _animar_sprite_erro()


func gerar_novo_alvo():
	var largura_barra = barra.size.x
	alvo_pos = randf_range(0.1, 0.9)
	alvo.position.x = alvo_pos * largura_barra


func atualizar_regressao(delta):
	if regredindo:
		progresso_geral -= regressao_velocidade * delta
		if progresso_geral <= 0.0:
			progresso_geral = 0.0
			regredindo = false


func _animar_sprite_acerto():
	sprite.frame = 0
	for i in range(1, 4):
		await get_tree().create_timer(0.1).timeout
		sprite.frame = i
	await get_tree().create_timer(0.1).timeout
	sprite.frame = 0


func _animar_sprite_erro():
	sprite.frame = 0
	await get_tree().create_timer(0.1).timeout
	sprite.frame = 4
	await get_tree().create_timer(0.2).timeout
	sprite.frame = 0
	gerar_novo_alvo()


# 🔹 Atualiza progresso no banco
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
		
func _carregar_skin(skin_id: int):
	if not is_instance_valid(sprite):
		return

	match skin_id:
		1:
			sprite.texture = preload("res://assets/characters/demian/demian-pulley.png")
		2:
			sprite.texture = preload("res://assets/characters/tim/tim-pulley.png")
		3:
			sprite.texture = preload("res://assets/characters/gian/gian-pulley.png")
		4:
			sprite.texture = preload("res://assets/characters/isabella/isabella-pulley.png")
		_:
			print("⚠ Skin ID inválido, carregando padrão (gian).")
			sprite.texture = preload("res://assets/characters/gian/gian-pulley.png")
