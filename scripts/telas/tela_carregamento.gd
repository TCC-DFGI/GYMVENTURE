extends CanvasLayer

var target_scene: String

func _ready():
	visible = false

func show_and_load(scene_path: String):
	visible = true
	target_scene = scene_path
	
	# força o Godot a desenhar a tela antes de prosseguir
	await get_tree().process_frame  

	# espera 1.5s (pode ajustar)
	await get_tree().create_timer(2).timeout  

	# agora sim troca de cena
	get_tree().change_scene_to_file(target_scene)

	# (opcional: só esconde se você for voltar pra mesma cena)
	visible = false
