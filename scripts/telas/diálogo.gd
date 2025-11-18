extends CanvasLayer

@onready var treinador: Sprite2D = $Treinador
@onready var fala_label:  RichTextLabel = $Fala

# Sequências diferentes dependendo da fase ou se o minigame foi feito
var falas = []
var frames = []
var texto_atual = 0
var escrevendo = false

func _ready():
	visible = false

func iniciar_dialogo(tipo: int):
	# Define falas e frames conforme o tipo (ex: "fase1", "fase2", "fase3", "ja_fez")
	match tipo:
		1:
			falas = [
				"Muito prazer, meu nome é Marcio, seu treinador (APERTE ESPAÇO PARA PROSSEGUIR)",
				"Aqui está a ficha de treino que montei para você",
				"Para interagir, pressione (E) ao aparecer uma EXCLAMAÇÃO (!)",
				"E para abrir as opções, aperte ESC",
				"Vamos lá pro seu primeiro treino"
			]
			frames = [0, 1, 2, 0, 1]  # frames do Treinador correspondentes
		2:
			falas = [
				"Seja bem-vindo de novo!",
				"O treino de hoje é de membros inferiores.",
				"Vai com tudo!"
			]
			frames = [2, 0, 1]
		3:
			falas = [
				"Bem vindo de novo campeão!",
				"Para o último treino da semana, vamos trabalhar o dorsal e bíceps",
				"Me avisa se tiver dúvida"
			]
			frames = [2, 1, 0]
		4:
			falas = [
				"Opa, que bom que voltou!",
				"Pode continuar de onde parou."
			]
			frames = [3, 0]
		5:
			falas = [
				"Parabéns, você concluiu seu treino",
				"Até semana que vem!!!"
			]
			frames = [2, 0]
	
	texto_atual = 0
	visible = true
	_mostrar_fala()

func _mostrar_fala():
	if texto_atual >= falas.size():
		_fim_dialogo()
		return
	
	treinador.frame = frames[texto_atual]
	fala_label.text = ""
	escrevendo = true
	_start_typing_effect(falas[texto_atual])

func _start_typing_effect(texto: String):
	var i = 0
	var chars = texto.length()
	while i < chars:
		fala_label.text += texto[i]
		i += 1
		await get_tree().create_timer(0.03).timeout  # velocidade da digitação
	await get_tree().create_timer(0.2).timeout
	escrevendo = false

func _input(event):
	if visible and event.is_action_pressed("ui_accept") and not escrevendo:
		texto_atual += 1
		_mostrar_fala()

func _fim_dialogo():
	visible = false
	var player = _get_player()
	if player:
		player.set_pode_mover(true)

func _get_player():
	var root = get_tree().get_current_scene()
	return root.get_node_or_null("player")
