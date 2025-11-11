extends Control

@onready var DemianBtn := $DemianBtn
@onready var FelipeBtn := $FelipeBtn
@onready var GianBtn := $GianBtn
@onready var IsabellaBtn := $IsabellaBtn
@onready var status_label := $StatusLabel

func _ready():
	DemianBtn.pressed.connect(_on_demian_pressed)
	FelipeBtn.pressed.connect(_on_felipe_pressed)
	GianBtn.pressed.connect(_on_gian_pressed)
	IsabellaBtn.pressed.connect(_on_isabella_pressed)

func _on_demian_pressed():
	escolher_skin(1)

func _on_felipe_pressed():
	escolher_skin(2)

func _on_gian_pressed():
	escolher_skin(3)

func _on_isabella_pressed():
	escolher_skin(4)

# Função chamada quando o jogador escolhe uma skin
func escolher_skin(num: int):
	var url = GameState.SUPABASE_URL + "/rest/v1/progress?user_id=eq.%s" % GameState.user_id
	var body = {"skin": num}
	var headers = GameState.get_headers()
	headers.append("Prefer: return=representation")

	var req = HTTPRequest.new()
	add_child(req)
	req.request(url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(body))
	await req.request_completed

	# Atualiza no GameState
	GameState.skin = num

	# Vai para a primeira fase
	TelaCarregamento.show_and_load("res://telas/fase_1.tscn")
