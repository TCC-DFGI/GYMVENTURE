extends Label

var ponto := 0

func _ready():
	# Garante que o Timer esteja conectado corretamente
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.start()

func _on_timer_timeout():
	ponto = (ponto + 1) % 4  # Vai de 0 a 3 e reinicia
	text = "CARREGANDO" + ".".repeat(ponto)
