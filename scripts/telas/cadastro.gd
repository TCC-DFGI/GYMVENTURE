extends Control

# Conexão com botões
func _ready():
	$NinePatchRect/VBoxContainer/CadastrarBtn.pressed.connect(_on_cadastrar_pressed)
	$NinePatchRect/VoltarBtn.pressed.connect(_on_voltar_pressed)

# Cria e retorna um HTTPRequest já configurado
func criar_request() -> HTTPRequest:
	var req = HTTPRequest.new()
	add_child(req)
	return req

func _on_cadastrar_pressed():
	var nome = $NinePatchRect/VBoxContainer/Nome.text.strip_edges()
	var email = $NinePatchRect/VBoxContainer/Email.text.strip_edges()
	var senha = $NinePatchRect/VBoxContainer/Senha.text.strip_edges()
	var conf_senha = $NinePatchRect/VBoxContainer/Confirmação_Senha.text.strip_edges()
	
	if nome == "" or email == "" or senha == "" or conf_senha == "":
		$NinePatchRect/VBoxContainer/StatusLabel.text = "Preencha todos os campos!"
		return
	if senha != conf_senha:
		$NinePatchRect/VBoxContainer/StatusLabel.text = "Senhas não coincidem"
		return

	# Endpoint da tabela users
	var url = GameState.SUPABASE_URL + "/rest/v1/users"
	var body = {
		"name": nome,
		"email": email,
		"password": senha
	}

	# Headers com autenticação e Prefer: return=representation
	var headers = GameState.get_headers()
	headers.append("Prefer: return=representation")

	var req = criar_request()
	req.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))

	var result = await req.request_completed
	if result[0] != OK:
		$NinePatchRect/VBoxContainer/StatusLabel.text = "Erro na conexão com Supabase."
		return

	# Analisa a resposta do Supabase
	var resposta_str = result[3].get_string_from_utf8()
	print_debug("Resposta criação usuário: %s" % resposta_str)  # DEBUG
	var resposta = JSON.parse_string(resposta_str)

	var user_id = null
	if resposta:
		if typeof(resposta) == TYPE_ARRAY and resposta.size() > 0:
			user_id = resposta[0].get("id", null)
		elif typeof(resposta) == TYPE_DICTIONARY:
			user_id = resposta.get("id", null)

	if user_id:
		var progresso_ok = await criar_progresso(user_id)
		if progresso_ok:
			$NinePatchRect/VBoxContainer/StatusLabel.text = "Cadastro realizado com sucesso!"
		else:
			$NinePatchRect/VBoxContainer/StatusLabel.text = "Cadastro realizado, mas não foi possível criar progresso."
	else:
		$NinePatchRect/VBoxContainer/StatusLabel.text = "Erro ao cadastrar usuário."

# Cria progresso inicial para o usuário
func criar_progresso(user_id: String) -> bool:
	var url = GameState.SUPABASE_URL + "/rest/v1/progress"
	var body = {
		"user_id": user_id,
		"fase_atual": 1,
		"posicao_x": 0,
		"posicao_y": 0,
		"minigame1_completado": false,
		"minigame2_completado": false
	}

	var headers = GameState.get_headers()
	headers.append("Prefer: return=representation")

	var req = criar_request()
	req.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	var result = await req.request_completed

	var resposta_str = result[3].get_string_from_utf8()
	print_debug("Resposta criação progresso: %s" % resposta_str)  # DEBUG

	if result[0] != OK:
		push_error("Erro ao criar progresso do usuário: %s" % result[0])
		return false

	var resposta = JSON.parse_string(resposta_str)
	if resposta and (typeof(resposta) == TYPE_ARRAY and resposta.size() > 0):
		return true
	return false

# Voltar para a tela inicial
func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://telas/tela_inicial.tscn")
