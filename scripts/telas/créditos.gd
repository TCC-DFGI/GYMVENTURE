extends Node2D

@onready var texto_label: RichTextLabel = $Texto

var falas: Array = [
	"Você completou o treino da semana, parabéns!!",
	"Até semana que vem, e lembre-se...",
	"""Essa é a essência do fisiculturismo - Vieira, Jorlan""",
	"Desenvolvido por DFGI",
	"Obrigado por jogar :)"
]
var index := 0
var escrevendo := false

func _ready():
	visible = true


# Chame isto para iniciar a sequência
func iniciar_finais(lista_falas: Array):
	falas = lista_falas
	index = 0
	visible = true
	_mostrar_fala()


func _mostrar_fala():
	if index >= falas.size():
		_finalizar()
		return

	texto_label.text = ""
	escrevendo = true
	_start_typing(falas[index])


func _start_typing(texto: String) -> void:
	var i := 0

	while i < texto.length():
		texto_label.text += texto[i]
		i += 1
		await get_tree().create_timer(0.03).timeout

	escrevendo = false


func _input(event):
	if not visible:
		return

	if event.is_action_pressed("ui_accept") and not escrevendo:
		index += 1
		_mostrar_fala()


func _finalizar():
	visible = false
	TelaCarregamento.show_and_load("res://telas/menu.tscn")
