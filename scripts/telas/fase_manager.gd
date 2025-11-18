extends Node

@onready var dialogo := $Diálogo
# Caminhos das cenas
const FASES = {
	1: "res://telas/fase_1.tscn",
	2: "res://telas/fase_2.tscn", #fase_2
	3: "res://telas/fase_3.tscn", 
	4: "res://telas/créditos.tscn" #menu --- depois de zerar tudo, volta pro menu
}

# Executa automaticamente ao carregar a fase
func _ready():
	await carregar_progresso()
	verificar_progresso()


# 🟢 Carrega progresso do jogador no banco
func carregar_progresso():
	if not GameState.user_id:
		push_error("Usuário não logado!")
		return

	var url = "%s/rest/v1/progress?user_id=eq.%s&select=*" % [GameState.SUPABASE_URL, GameState.user_id]
	var headers = GameState.get_headers()

	var req = HTTPRequest.new()
	add_child(req)
	req.request(url, headers, HTTPClient.METHOD_GET)

	var result = await req.request_completed
	var response_code = result[1]
	var body = result[3].get_string_from_utf8()

	if response_code != 200:
		push_error("Erro ao buscar progresso (HTTP %s)" % str(response_code))
		return

	var json = JSON.new()
	var parse_result = json.parse(body)

	if parse_result != OK:
		push_error("❌ Erro ao interpretar JSON: %s" % body)
		return

	var dados = json.get_data()

	if not dados or dados.size() == 0:
		push_error("⚠️ Nenhum progresso encontrado no banco.")
		print("Resposta do Supabase:", body)
		return

	var registro = dados[0]
	GameState.fase_atual = int(registro.get("fase_atual", 1))
	GameState.minigame1_completado = registro.get("minigame1_completado", false)
	GameState.minigame2_completado = registro.get("minigame2_completado", false)

	print("📗 Progresso carregado: fase=%d | mini1=%s | mini2=%s" %
		[GameState.fase_atual, str(GameState.minigame1_completado), str(GameState.minigame2_completado)])


# 🔄 Verifica se pode avançar de fase
func verificar_progresso():
	var fase = GameState.fase_atual
	var mini1 = GameState.minigame1_completado
	var mini2 = GameState.minigame2_completado

	print("📘 Verificando progresso: fase=%d, mini1=%s, mini2=%s" % [fase, str(mini1), str(mini2)])

	if mini1 and mini2:
		if fase == 1:
			await atualizar_fase(2)
			GameState.dialogo_fase_mostrado = false
			TelaCarregamento.show_and_load(FASES[2])
		if fase == 2:
			await atualizar_fase(3)
			GameState.dialogo_fase_mostrado = false
			TelaCarregamento.show_and_load(FASES[3])
		elif fase == 3:
			await resetar_progresso()
			GameState.dialogo_fase_mostrado = false
			TelaCarregamento.show_and_load(FASES[4])
	else:
		print("⏳ Ainda há minigames pendentes nesta fase.")


# 🧠 Atualiza fase no banco
func atualizar_fase(nova_fase: int):
	if not GameState.user_id:
		return

	GameState.fase_atual = nova_fase
	GameState.minigame1_completado = false
	GameState.minigame2_completado = false
	GameState.posicao_x = 392
	GameState.posicao_y = 256

	var url = "%s/rest/v1/progress?user_id=eq.%s" % [GameState.SUPABASE_URL, GameState.user_id]
	var body = {
		"fase_atual": nova_fase,
		"minigame1_completado": false,
		"minigame2_completado": false
	}

	var headers = GameState.get_headers()
	headers.append("Prefer: return=representation")

	var req = HTTPRequest.new()
	add_child(req)
	req.request(url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(body))
	await req.request_completed

	print("✅ Fase atualizada para %d" % nova_fase)


# 🧹 Reseta tudo (volta ao menu)
func resetar_progresso():
	if not GameState.user_id:
		return

	GameState.fase_atual = 1
	GameState.minigame1_completado = false
	GameState.minigame2_completado = false
	GameState.posicao_x = 392
	GameState.posicao_y = 256

	var url = "%s/rest/v1/progress?user_id=eq.%s" % [GameState.SUPABASE_URL, GameState.user_id]
	var body = {
		"fase_atual": 1,
		"minigame1_completado": false,
		"minigame2_completado": false
	}

	var headers = GameState.get_headers()
	headers.append("Prefer: return=representation")

	var req = HTTPRequest.new()
	add_child(req)
	req.request(url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(body))
	await req.request_completed

	print("🔁 Progresso resetado, voltando ao menu...")
