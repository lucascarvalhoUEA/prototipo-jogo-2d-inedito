## AlienCapture.gd
## Alien com feixe de tração. Fica parado ou se move lentamente no topo da tela,
## disparando o feixe periodicamente para tentar capturar o jogador.

extends AlienBase

@export var beam_interval: float = 3.0
@export var beam_duration: float = 2.0
@export var drift_speed: float = 60.0

var _beam: Node2D = null
var _beam_active: bool = false
var _beam_timer: float = 0.0
var _drift_dir: float = 1.0
var _screen_width: float = 1280.0


func _on_ready() -> void:
	_screen_width = get_viewport_rect().size.x
	_drift_dir = 1.0 if randf() > 0.5 else -1.0
	_beam = $TractorBeam as Node2D
	damage_on_contact = false
	score_value = 200
	if _beam:
		_beam.call("set_active", false)
	var start_y: float = position.y
	var tween := create_tween().set_loops()
	tween.tween_property(self, "position:y", start_y + 10.0, 1.0).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", start_y - 10.0, 1.0).set_ease(Tween.EASE_IN_OUT)


func _move(delta: float) -> void:
	velocity.x = drift_speed * speed_multiplier * _drift_dir
	velocity.y = 0.0
	if position.x >= _screen_width - 40.0 and _drift_dir > 0.0:
		_drift_dir = -1.0
	elif position.x <= 40.0 and _drift_dir < 0.0:
		_drift_dir = 1.0

	_beam_timer += delta
	if not _beam_active and _beam_timer >= beam_interval:
		_activate_beam()
	elif _beam_active and _beam_timer >= beam_duration:
		_deactivate_beam()


func _activate_beam() -> void:
	_beam_active = true
	_beam_timer = 0.0
	if _beam:
		_beam.call("set_active", true)


func _deactivate_beam() -> void:
	_beam_active = false
	_beam_timer = 0.0
	if _beam:
		_beam.call("set_active", false)
