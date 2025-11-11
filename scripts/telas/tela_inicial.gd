extends Control

@onready var cadastro_btn := $CadastroBtn
@onready var login_btn := $LoginBtn
@onready var sair_btn := $SairBtn

func _ready():
	cadastro_btn.pressed.connect(_on_cadastro_pressed)
	login_btn.pressed.connect(_on_login_pressed)
	sair_btn.pressed.connect(_on_sair_pressed)

func _on_cadastro_pressed():
	get_tree().change_scene_to_file("res://telas/cadastro.tscn")

func _on_login_pressed():
	get_tree().change_scene_to_file("res://telas/login.tscn")

func _on_sair_pressed():
	get_tree().quit()
