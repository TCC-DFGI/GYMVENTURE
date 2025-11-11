extends CharacterBody2D

@export var speed : int = 35.0
@onready var animations = $animacao
@onready var sprite = $textura  # AnimatedSprite2D ou Sprite2D

var last_direction := "down"  # Guarda a última direção de movimento

func handleInput():
	var moveDirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = moveDirection * speed

func updateAnimation():
	if velocity.length() == 0:
		# Jogador parado → toca a animação idle baseada na última direção
		match last_direction:
			"up":
				animations.play("up")  # idle para cima
			"down":
				animations.play("down")  # idle para baixo
			"side":
				animations.play("side")  # idle para os lados
	else:
		# Jogador se movendo → animação de andar
		if abs(velocity.x) > abs(velocity.y):
			animations.play("lado")
			sprite.flip_h = velocity.x < 0
			last_direction = "side"  # atualiza a última direção
		elif velocity.y < 0:
			animations.play("cima")
			last_direction = "up"
		else:
			animations.play("baixo")
			last_direction = "down"

func _physics_process(delta):
	handleInput()
	move_and_slide()
	updateAnimation()
	z_index = int(position.y)
