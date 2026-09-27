## TractorBeam.gd
## Feixe de tração do alien capturador.
## Emite um cone/raio abaixo da nave. Se o jogador estiver dentro, é puxado para cima.

extends Node2D

signal player_entered_beam()
signal player_exited_beam()

@export var beam_length: float = 200.0
@export var beam_width_top: float = 20.0
@export var beam_width_bottom: float = 80.0
@export var beam_color: Color = Color(0.3, 0.9, 1.0, 0.45)
@export var beam_active: bool = true

var _player_inside: bool = false
var _pulse_timer: float = 0.0


func _ready() -> void:
	var col: CollisionShape2D = $Area2D/CollisionShape2D
	col.shape = _build_shape()


func _process(delta: float) -> void:
	if not beam_active:
		return
	_pulse_timer += delta
	beam_color.a = 0.3 + 0.2 * sin(_pulse_timer * 4.0)
	queue_redraw()


func _draw() -> void:
	if not beam_active:
		return
	var points := PackedVector2Array([
		Vector2(-beam_width_top * 0.5, 0),
		Vector2(beam_width_top * 0.5, 0),
		Vector2(beam_width_bottom * 0.5, beam_length),
		Vector2(-beam_width_bottom * 0.5, beam_length)
	])
	draw_colored_polygon(points, beam_color)
	draw_polyline(points + PackedVector2Array([points[0]]),
		Color(0.6, 1.0, 1.0, 0.7), 2.0)


func _build_shape() -> ConvexPolygonShape2D:
	var shape := ConvexPolygonShape2D.new()
	shape.points = PackedVector2Array([
		Vector2(-beam_width_top * 0.5, 0),
		Vector2(beam_width_top * 0.5, 0),
		Vector2(beam_width_bottom * 0.5, beam_length),
		Vector2(-beam_width_bottom * 0.5, beam_length)
	])
	return shape


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		body.call("set_captured", true)
		emit_signal("player_entered_beam")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		body.call("set_captured", false)
		emit_signal("player_exited_beam")


func set_active(value: bool) -> void:
	beam_active = value
	# CollisionPolygon2D não existe nesta cena — usamos CollisionShape2D
	var col: CollisionShape2D = $Area2D/CollisionShape2D
	col.disabled = not value
	if not value and _player_inside:
		var player: Node = get_tree().get_first_node_in_group("player")
		if player:
			player.call("set_captured", false)
		_player_inside = false
