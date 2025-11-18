extends Control

@onready var iniciar_btn := $IniciarBtn
@onready var config_btn := $ConfigBtn
@onready var sair_btn := $SairBtn
@onready var status_label := $StatusLabel
@onready var op :=$Pause

func _ready():
	iniciar_btn.pressed.connect(_on_iniciar_pressed)
	config_btn.pressed.connect(_on_config_pressed)
	sair_btn.pressed.connect(_on_sair_pressed)
	
	# Mensagem de boas-vindas
	if GameState.user_name != "":
		status_label.text = "Olá, %s!" % GameState.user_name
	else:
		status_label.text = "Bem-vindo!"

# --- Botão INICIAR ---
func _on_iniciar_pressed() -> void:
	if GameState.user_id == "":
		status_label.text = "Faça login novamente."
		return

	status_label.text = "Carregando progresso..."
	await carregar_progresso()

	# Verifica se tem skin escolhida
	if GameState.skin == 0:
		get_tree().change_scene_to_file("res://telas/skins.tscn")
		return
	
	# Carrega a fase correta
	match GameState.fase_atual:
		1: TelaCarregamento.show_and_load("res://telas/fase_1.tscn")
		2: TelaCarregamento.show_and_load("res://telas/fase_2.tscn")
		3: TelaCarregamento.show_and_load("res://telas/fase_3.tscn")
		_: TelaCarregamento.show_and_load("res://telas/fase_1.tscn")

# --- Função para carregar o progresso do Supabase ---
func carregar_progresso() -> void:
	var url = "%s/rest/v1/progress?user_id=eq.%s" % [GameState.SUPABASE_URL, GameState.user_id]
	var headers = GameState.get_headers()
	headers.append("Prefer: return=representation")

	var req = HTTPRequest.new()
	add_child(req)
	req.request(url, headers, HTTPClient.METHOD_GET)
	var result = await req.request_completed
	req.queue_free()

	if result[0] != OK:
		status_label.text = "Erro ao buscar progresso."
		push_error("Menu: Falha ao carregar progresso do Supabase")
		return

	var body_str = result[3].get_string_from_utf8()
	var resposta = JSON.parse_string(body_str)
	if typeof(resposta) != TYPE_ARRAY or resposta.size() == 0:
		# Nenhum progresso encontrado, cria inicial
		await criar_progresso_inicial(GameState.user_id)
		return

	var progress = resposta[0]
	GameState.fase_atual = progress.get("fase_atual", 1)
	GameState.posicao_x = progress.get("posicao_x", 0)
	GameState.posicao_y = progress.get("posicao_y", 0)
	GameState.minigame1_completado = progress.get("minigame1_completado", false)
	GameState.minigame2_completado = progress.get("minigame2_completado", false)
	GameState.skin = progress.get("skin", 0)
	
	print("Menu: progresso carregado -> Fase:", GameState.fase_atual, "Posição:", GameState.posicao_x, GameState.posicao_y, "Skin:", GameState.skin)

# --- Cria progresso inicial caso não exista ---
func criar_progresso_inicial(user_id: String) -> void:
	var url = GameState.SUPABASE_URL + "/rest/v1/progress"
	var body = {
		"user_id": user_id,
		"fase_atual": 1,
		"posicao_x": 0,
		"posicao_y": 0,
		"minigame1_completado": false,
		"minigame2_completado": false,
		"skin": 0
	}
	var headers = GameState.get_headers()
	headers.append("Prefer: return=representation")

	var req = HTTPRequest.new()
	add_child(req)
	req.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	await req.request_completed
	req.queue_free()

	print("Menu: progresso inicial criado para o usuário:", user_id)

# --- Botão CONFIGURAÇÕES ---
func _on_config_pressed() -> void:
	op.visible = true

# --- Botão SAIR ---
func _on_sair_pressed() -> void:
	# Limpa dados do GameState
	GameState.user_id = ""
	GameState.user_name = ""
	GameState.fase_atual = 1
	GameState.posicao_x = 0
	GameState.posicao_y = 0
	GameState.skin = 0
	GameState.minigame1_completado = false
	GameState.minigame2_completado = false

	status_label.text = "Saindo..."
	get_tree().change_scene_to_file("res://telas/tela_inicial.tscn")
