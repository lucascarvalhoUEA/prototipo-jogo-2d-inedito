## AlienPatroller.gd
## Voa horizontalmente de uma borda a outra da tela.
## Ao chegar numa borda, inverte a direção e desce ligeiramente.

extends AlienBase

@export var vertical_step: float = 48.0

var _direction: float = 1.0
var _screen_width: float = 1280.0


func _on_ready() -> void:
	_screen_width = get_viewport_rect().size.x
	_direction = 1.0 if randf() > 0.5 else -1.0
	# Bob vertical suave
	var start_y: float = position.y
	var tween := create_tween().set_loops()
	tween.tween_property(self, "position:y", start_y + 8.0, 0.6).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", start_y - 8.0, 0.6).set_ease(Tween.EASE_IN_OUT)


func _move(_delta: float) -> void:
	velocity.x = base_speed * speed_multiplier * _direction
	velocity.y = 0.0

	var half_w: float = 30.0
	if position.x >= _screen_width - half_w and _direction > 0.0:
		_direction = -1.0
		position.y += vertical_step
		_flip_sprite()
	elif position.x <= half_w and _direction < 0.0:
		_direction = 1.0
		position.y += vertical_step
		_flip_sprite()


func _flip_sprite() -> void:
	var spr: Node2D = $Sprite2D
	spr.set("flip_h", _direction < 0.0)
