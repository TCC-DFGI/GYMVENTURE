extends Node

# --- Dados do usuário logado ---
var user_id: String = ""
var user_name: String = ""

# --- Progresso atual ---
var fase_atual: int = 1
var posicao_x: float = 0
var posicao_y: float = 0
var minigame1_completado: bool = false
var minigame2_completado: bool = false
var skin: int = 0  # número da skin escolhida (0 a 4)

var dialogo_fase_mostrado: bool = false

# --- Node do Player ---
var player_node: Node = null


# 🚨 Supabase Config
const SUPABASE_URL = "https://irhheqjgvqbgbssuoaul.supabase.co"
const SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlyaGhlcWpndnFiZ2Jzc3VvYXVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkyNTQ1MzcsImV4cCI6MjA3NDgzMDUzN30.rYoozKOxnafxfUVyLYnDqARRmfP5sZx7QE6Q2tvcLxc"


# --- Headers padrão ---
func get_headers() -> Array:
	return [
		"apikey: %s" % SUPABASE_KEY,
		"Authorization: Bearer %s" % SUPABASE_KEY,
		"Content-Type: application/json"
	]


# --- Função para SALVAR progresso global ---
func salvar_progresso_global() -> void:
	if not player_node:
		push_error("❌ Player não registrado no GameState!")
		return

	if user_id == "":
		push_error("❌ Nenhum usuário logado. Salvamento cancelado.")
		return

	# Atualiza GameState com posição atual
	posicao_x = player_node.position.x
	posicao_y = player_node.position.y

	if posicao_x == 0 and posicao_y == 0:
		print("⚠️ Posição (0,0) detectada — salvamento ignorado.")
		return

	var url = "%s/rest/v1/progress?on_conflict=user_id" % SUPABASE_URL
	var body = [{
		"user_id": user_id,
		"fase_atual": fase_atual,
		"posicao_x": posicao_x,
		"posicao_y": posicao_y,
		"minigame1_completado": minigame1_completado,
		"minigame2_completado": minigame2_completado,
		"skin": skin
	}]
	var headers = get_headers()
	headers.append("Prefer: return=representation")

	var req = HTTPRequest.new()
	add_child(req)
	req.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	var result = await req.request_completed

	if result[0] == OK:
		print("✅ Progresso salvo com sucesso no Supabase!")
		print("   user_id:", user_id)
		print("   posição:", posicao_x, posicao_y)
	else:
		push_error("❌ Erro ao salvar progresso!")

	req.queue_free()


# --- Função para CARREGAR progresso global ---
func carregar_progresso_global() -> void:
	if user_id == "":
		push_error("❌ Nenhum usuário logado. Não é possível carregar progresso.")
		return

	var url = "%s/rest/v1/progress?user_id=eq.%s" % [SUPABASE_URL, user_id]
	var headers = get_headers()
	headers.append("Prefer: return=representation")

	var req = HTTPRequest.new()
	add_child(req)
	req.request(url, headers, HTTPClient.METHOD_GET)
	var result = await req.request_completed

	if result[0] != OK:
		push_error("❌ Erro ao buscar progresso no Supabase.")
		return

	var body = result[3].get_string_from_utf8()
	var dados = JSON.parse_string(body)

	if typeof(dados) == TYPE_ARRAY and dados.size() > 0:
		var p = dados[0]

		fase_atual = p.get("fase_atual", 1)
		posicao_x = p.get("posicao_x", 0)
		posicao_y = p.get("posicao_y", 0)
		minigame1_completado = p.get("minigame1_completado", false)
		minigame2_completado = p.get("minigame2_completado", false)
		skin = p.get("skin", 0)

		print("✅ Progresso carregado do Supabase:")
		print("   Fase:", fase_atual)
		print("   Posição:", posicao_x, posicao_y)
		print("   Skin:", skin)
	else:
		print("⚠️ Nenhum progresso encontrado para este usuário.")
		fase_atual = 1
		posicao_x = 0
		posicao_y = 0
		skin = 0

	req.queue_free()
# --- Controle para diferenciar nova fase de retorno ---
var fase_recem_carregada: bool = true
