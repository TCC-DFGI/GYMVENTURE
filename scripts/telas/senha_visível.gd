extends NinePatchRect

@onready var senha_input: LineEdit = $VBoxContainer/Senha
@onready var senha_input2: LineEdit = $VBoxContainer/Confirmação_Senha
@onready var olho_btn: TextureButton = $TextureButton
# Ícones de olho aberto/fechado
var olho_aberto = preload("res://assets/ui/botoes/olho_aberto.png")
var olho_fechado = preload("res://assets/ui/botoes/olho_fechado.png")

var senha_visivel := false

func _ready():
	# Começa com senha escondida e ícone de olho fechado
	senha_input.secret = true
	if senha_input2:
		senha_input2.secret = true
	olho_btn.texture_normal = olho_fechado
	
	olho_btn.pressed.connect(_on_olho_pressed)

func _on_olho_pressed():
	senha_visivel = !senha_visivel
	
	senha_input.secret = not senha_visivel
	if senha_input2:
		senha_input2.secret = not senha_visivel
	
	if senha_visivel:
		olho_btn.texture_normal = olho_aberto
	else:
		olho_btn.texture_normal = olho_fechado
