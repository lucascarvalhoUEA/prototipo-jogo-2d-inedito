## AlienCapture.gd
## Alien com feixe de tração PERMANENTE.
## Ele persegue ativamente o eixo X do jogador para tentar sugá-lo.

extends AlienBase

@export var max_drift_speed: float = 70.0
@export var acceleration: float = 120.0
var _beam: Node2D = null

func _on_ready() -> void:
	_setup_sprite()
	_beam = $TractorBeam as Node2D
	damage_on_contact = true
	score_value = 250
	
	# Entrada suave na tela
	var target_y := randf_range(50.0, 100.0)
	var entry_tween := create_tween()
	entry_tween.tween_property(self, "position:y", target_y, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	entry_tween.tween_callback(_start_floating.bind(target_y))

func _start_floating(base_y: float) -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(self, "position:y", base_y + 12.0, 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", base_y - 12.0, 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func _move(delta: float) -> void:
	# Encontra o jogador e o persegue no eixo X
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		var diff = player.global_position.x - global_position.x
		# Move na direção do jogador, mas com inércia para não ser tão agressivo
		if abs(diff) > 15.0:
			var dir = sign(diff)
			var target_vel = max_drift_speed * speed_multiplier * dir
			velocity.x = move_toward(velocity.x, target_vel, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
	
	velocity.y = 0.0

func _setup_sprite() -> void:
	var old_sprite = get_node_or_null("Sprite2D")
	if old_sprite:
		old_sprite.queue_free()
	
	var spr = Sprite2D.new()
	spr.name = "MainSprite"
	var img = Image.new()
	if img.load("res://assets/sprites/alien_capture.png") == OK:
		img.generate_mipmaps()
		spr.texture = ImageTexture.create_from_image(img)
	spr.scale = Vector2(0.12, 0.12)
	add_child(spr)
	move_child(spr, 0)
