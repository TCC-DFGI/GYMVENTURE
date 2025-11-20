extends Control

@onready var email_input := $NinePatchRect/VBoxContainer/Email
@onready var senha_input := $NinePatchRect/VBoxContainer/Senha
@onready var login_btn := $NinePatchRect/VBoxContainer/LoginBtn
@onready var voltar_btn := $NinePatchRect/VoltarBtn
@onready var status_label := $NinePatchRect/VBoxContainer/StatusLabel

func _ready():
	login_btn.pressed.connect(_on_login_pressed)
	voltar_btn.pressed.connect(_on_voltar_pressed)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_login_pressed()
		var foco = get_viewport().gui_get_focus_owner()
		if foco is LineEdit:
			_on_login_pressed()
			get_viewport().set_input_as_handled()

func _on_login_pressed():
	var email = email_input.text.strip_edges()
	var senha = senha_input.text.strip_edges()
	
	if email == "" or senha == "":
		status_label.text = "Preencha todos os campos!"
		return

	# Consulta na tabela users
	var url = GameState.SUPABASE_URL + "/rest/v1/users?email=eq.%s&password=eq.%s" % [email, senha]
	var headers = GameState.get_headers()
	headers.append("Prefer: return=representation")

	var req = HTTPRequest.new()
	add_child(req)
	req.request(url, headers, HTTPClient.METHOD_GET)

	var result = await req.request_completed
	if result[0] != OK:
		status_label.text = "Erro na conexão."
		return

	var body_str = result[3].get_string_from_utf8()
	var resposta = JSON.parse_string(body_str)

	if typeof(resposta) == TYPE_ARRAY and resposta.size() > 0:
		var user = resposta[0]
		var user_id = user.get("id", null)
		var nome = user.get("name", "")
		
		if user_id:
			# Salva informações básicas no GameState
			GameState.user_id = user_id
			GameState.user_name = nome
			
			status_label.text = "Bem-vindo ao Gymventure, %s!" % nome
			await get_tree().create_timer(2).timeout
			get_tree().change_scene_to_file("res://telas/menu.tscn")
		else:
			status_label.text = "Erro ao carregar usuário."
	else:
		status_label.text = "Email ou senha inválidos."

func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://telas/tela_inicial.tscn")
