extends Node

@onready var player: AudioStreamPlayer = AudioStreamPlayer.new()
var current_music: String = ""
var last_scene_path: String = ""

var music_map := {
	"res://telas/tela_inicial.tscn": "res://tcc-musica/musica-menu(1).mp3",
	"res://telas/cadastro.tscn": "res://tcc-musica/musica-menu(1).mp3",
	"res://telas/login.tscn": "res://tcc-musica/musica-menu(1).mp3",
	"res://telas/menu.tscn": "res://tcc-musica/musica-menu(1).mp3",
	"res://telas/fase_1.tscn": "res://tcc-musica/Musica-principal(1).mp3",
	"res://telas/minigames/minigame_supino.tscn": "res://tcc-musica/musica-mg(1).mp3",
	"res://telas/minigames/minigame_triceps.tscn": "res://tcc-musica/musica-mg(1).mp3",
	"res://telas/fase_2.tscn": "res://tcc-musica/musica-principal(1).mp3",
	"res://telas/minigames/minigame_agachamento.tscn": "res://tcc-musica/musica-mg(1).mp3",
	"res://telas/minigames/minigame_panturrilha.tscn": "res://tcc-musica/musica-mg(1).mp3",
	"res://telas/fase_3.tscn": "res://tcc-musica/musica-principal(1).mp3",
	"res://telas/minigames/minigame_rosca.tscn": "res://tcc-musica/musica-mg(1).mp3",
	"res://telas/minigames/minigame_pulley.tscn": "res://tcc-musica/musica-mg(1).mp3"
}

func _ready():
	add_child(player)
	player.bus = "Master"
	player.volume_db = -25
	player.autoplay = false
	print("[Music] Iniciado!")

	# Espera a cena estabilizar antes de tocar qualquer música
	await get_tree().create_timer(0.5).timeout

	if get_tree().current_scene:
		var start_path = get_tree().current_scene.scene_file_path
		last_scene_path = start_path
		if music_map.has(start_path):
			var initial_music = music_map[start_path]
			print("[Music] Cena inicial detectada:", start_path)
			_tocar_musica(initial_music)
		else:
			print("[Music] Nenhuma música inicial encontrada para:", start_path)

	monitorar_cenas()


func monitorar_cenas() -> void:
	while true:
		await get_tree().create_timer(0.5).timeout
		if get_tree().current_scene:
			var path = get_tree().current_scene.scene_file_path
			if path != last_scene_path:
				last_scene_path = path
				_on_scene_changed(path)


func _on_scene_changed(path: String) -> void:
	print("[Music] Cena mudou para:", path)
	if not music_map.has(path):
		print("[Music] Nenhuma música mapeada para:", path)
		return

	var new_music = music_map[path]
	if new_music == current_music:
		print("[Music] Mesma música — mantendo reprodução.")
		return

	if not FileAccess.file_exists(new_music):
		push_error("[Music] ERRO: Arquivo não encontrado:", new_music)
		return

	# 🔇 para música atual antes de tocar a próxima
	player.stop()
	current_music = ""  
	print("[Music] Parando música atual e aguardando 0.7s para nova...")

	await get_tree().create_timer(0.7).timeout  # ⏱ delay de 0.7s antes da nova
	_tocar_musica(new_music)


func _tocar_musica(music_path: String) -> void:
	print("[Music] Trocando para:", music_path)
	var stream = load(music_path)
	if not stream:
		push_error("[Music] Falha ao carregar:", music_path)
		return
	if stream is AudioStream: 
		# No Godot 4, o AudioStream carregado (e.g., AudioStreamMP3) possui a propriedade 'loop'.
		# Verificamos se a propriedade existe antes de configurá-la.
		if stream.has_method("set_loop"): # Boa prática para garantir compatibilidade
			stream.loop = true
		elif stream.has_property("loop"): # Melhor verificação para propriedades
			stream.loop = true
		
		# Alternativamente, para streams que suportam loop_mode:
		# if stream.has_property("loop_mode"):
		#     stream.loop_mode = AudioStream.LOOP_MODE_FORWARD # Isso é para AudioStreamPlayback, não para o recurso AudioStream

	player.stop()
	player.stream = stream
	player.play()
	current_music = music_path
	print("[Music] Tocando agora:", music_path)
