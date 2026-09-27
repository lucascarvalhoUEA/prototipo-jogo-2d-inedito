## AlienShooter.gd
## Fica posicionado em algum ponto da tela e dispara projéteis na direção do jogador.

extends AlienBase

@export var fire_interval: float = 2.5
@export var projectile_speed: float = 250.0
@export var drift_speed: float = 40.0

var _fire_timer: float = 0.0
var _drift_dir: float = 1.0
var _screen_width: float = 1280.0


func _on_ready() -> void:
	_screen_width = get_viewport_rect().size.x
	_drift_dir = 1.0 if randf() > 0.5 else -1.0
	damage_on_contact = true
	score_value = 150
	_fire_timer = randf_range(0.0, fire_interval)


func _move(delta: float) -> void:
	velocity.x = drift_speed * speed_multiplier * _drift_dir
	velocity.y = 0.0
	if position.x >= _screen_width - 40.0:
		_drift_dir = -1.0
	elif position.x <= 40.0:
		_drift_dir = 1.0

	_fire_timer += delta
	if _fire_timer >= fire_interval:
		_fire_timer = 0.0
		_shoot()


func _shoot() -> void:
	if not is_instance_valid(_player):
		return
	var dir: Vector2 = (_player.global_position - global_position).normalized()
	var proj: RigidBody2D = _create_projectile()
	proj.global_position = global_position
	get_tree().current_scene.add_child(proj)
	proj.linear_velocity = dir * projectile_speed * speed_multiplier


func _create_projectile() -> RigidBody2D:
	var proj := RigidBody2D.new()
	proj.gravity_scale = 0.0
	proj.collision_layer = 4
	proj.collision_mask = 2
	proj.contact_monitor = true
	proj.max_contacts_reported = 1

	var shape := CircleShape2D.new()
	shape.radius = 6.0
	var col := CollisionShape2D.new()
	col.shape = shape
	proj.add_child(col)

	var vis := Node2D.new()
	vis.set_script(preload("res://scripts/ProjectileVisual.gd"))
	proj.add_child(vis)

	var timer := Timer.new()
	timer.wait_time = 4.0
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(proj.queue_free)
	proj.add_child(timer)

	proj.body_entered.connect(_on_projectile_hit.bind(proj))
	return proj


func _on_projectile_hit(body: Node, proj: Node) -> void:
	if body.is_in_group("player"):
		body.call("take_damage")
	if is_instance_valid(proj):
		proj.queue_free()
