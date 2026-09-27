## ProjectileVisual.gd
## Visual simples de projétil: círculo laranja com rastro.

extends Node2D

var _trail: Array[Vector2] = []
const TRAIL_LEN := 8


func _process(_delta: float) -> void:
	_trail.append(get_parent().global_position)
	if _trail.size() > TRAIL_LEN:
		_trail.pop_front()
	queue_redraw()


func _draw() -> void:
	# Rastro
	for i in range(_trail.size()):
		var alpha := float(i) / float(TRAIL_LEN)
		draw_circle(to_local(_trail[i]), 4.0 * alpha, Color(1.0, 0.4, 0.1, alpha * 0.6))
	# Círculo principal
	draw_circle(Vector2.ZERO, 6.0, Color(1.0, 0.6, 0.2, 1.0))
	draw_circle(Vector2.ZERO, 3.0, Color(1.0, 1.0, 0.5, 1.0))
