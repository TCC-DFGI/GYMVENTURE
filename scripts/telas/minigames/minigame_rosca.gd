extends Node2D

@export var academia: String
@export var total_reps: int = 5
@export var margem_erro: float = 25.0  # raio de acerto em pixels
@export var velocidade_base: float = 2.0
@export var aumento_velocidade: float = 0.2

@onready var circulo := $Circulo
@onready var pointer := $Circulo/Pointer
@onready var alvos := [$Circulo/Alvo1, $Circulo/Alvo2, $Circulo/Alvo3]
@onready var rep_label := $RepLabel
@onready var sprite := $gian

var current_reps := 0
var velocidade_angular := velocidade_base
var sentido := 1
var angulo := 0.0
var alvos_restantes := []
var pode_jogar := true

func _ready():
	_carregar_skin(GameState.skin)
	randomize()
	rep_label.text = "%d / %d" % [current_reps, total_reps]
	gerar_novos_alvos()
	definir_sentido_aleatorio()


func _process(delta):
	if not pode_jogar:
		return

	angulo += sentido * velocidade_angular * delta
	atualizar_pointer()


func atualizar_pointer():
	var raio = 100.0  # tamanho do círculo
	var pos_local = Vector2(cos(angulo), sin(angulo)) * raio
	pointer.position = pos_local


func _unhandled_input(event):
	if not pode_jogar:
		return

	if event.is_action_pressed("ui_accept"):
		var acertou := false
		for alvo in alvos_restantes:
			# compara posições relativas ao mesmo pai ($Circulo)
			if pointer.position.distance_to(alvo.position) <= margem_erro:
				acertou = true
				alvos_restantes.erase(alvo)
				alvo.visible = false
				break

		if acertou:
			print("🎯 Acertou um alvo!")
			if alvos_restantes.size() == 0:
				await _contar_repeticao()
		else:
			print("❌ Errou!")
			await _animar_sprite_erro()
			# 👇 Reinicia a rodada ao errar
			gerar_novos_alvos()
			definir_sentido_aleatorio()


func _contar_repeticao():
	pode_jogar = false
	current_reps += 1
	rep_label.text = "%d / %d" % [current_reps, total_reps]
	await _animar_sprite_acerto()

	if current_reps >= total_reps:
		print("🏁 Minigame rosca completo! Salvando progresso...")
		await atualizar_minigame2_no_banco()
		TelaCarregamento.show_and_load(academia)
		return

	# Reinicia rodada
	velocidade_angular += aumento_velocidade
	gerar_novos_alvos()
	definir_sentido_aleatorio()
	pode_jogar = true


func gerar_novos_alvos():
	alvos_restantes.clear()
	var raio = 100.0

	for alvo in alvos:
		var ang = randf_range(0, TAU)
		var pos_local = Vector2(cos(ang), sin(ang)) * raio
		alvo.position = pos_local   # agora posição local ao círculo
		alvo.visible = true
		alvos_restantes.append(alvo)


func definir_sentido_aleatorio():
	sentido = 1 if randf() < 0.5 else -1


func _animar_sprite_acerto():
	sprite.frame = 0
	for i in range(1, 4):
		await get_tree().create_timer(0.1).timeout
		sprite.frame = i
	await get_tree().create_timer(0.1).timeout
	sprite.frame = 0


func _animar_sprite_erro():
	pode_jogar = false
	sprite.frame = 0
	await get_tree().create_timer(0.1).timeout
	sprite.frame = 4
	await get_tree().create_timer(0.2).timeout
	sprite.frame = 0
	pode_jogar = true


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
		return

	match skin_id:
		1:
			sprite.texture = preload("res://assets/characters/demian/demian-rosca.png")
		2:
			sprite.texture = preload("res://assets/characters/tim/tim-rosca.png")
		3:
			sprite.texture = preload("res://assets/characters/gian/gian-rosca.png")
		4:
			sprite.texture = preload("res://assets/characters/isabella/isabella-rosca.png")
		_:
			print("⚠ Skin ID inválido, carregando padrão (gian).")
			sprite.texture = preload("res://assets/characters/gian/gian-rosca.png")
