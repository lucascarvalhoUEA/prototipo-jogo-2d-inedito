## TractorBeam.gd
## Feixe de tração contínuo. Puxa qualquer player que entrar na área.

extends Node2D

@export var beam_length: float = 350.0
@export var beam_width_top: float = 40.0
@export var beam_width_bottom: float = 140.0
@export var beam_color: Color = Color(0.3, 0.9, 1.0, 0.45)

var _player_inside: bool = false
var _pulse_timer: float = 0.0
@onready var area: Area2D = $Area2D

func _ready() -> void:
	var col := CollisionPolygon2D.new()
	col.polygon = PackedVector2Array([
		Vector2(-beam_width_top * 0.5, 0),
		Vector2(beam_width_top * 0.5, 0),
		Vector2(beam_width_bottom * 0.5, beam_length),
		Vector2(-beam_width_bottom * 0.5, beam_length)
	])
	area.add_child(col)
	var old_col = area.get_node_or_null("CollisionShape2D")
	if old_col:
		old_col.queue_free()

func _process(delta: float) -> void:
	_pulse_timer += delta
	beam_color.a = 0.35 + 0.15 * sin(_pulse_timer * 6.0)
	queue_redraw()

func _physics_process(_delta: float) -> void:
	var bodies = area.get_overlapping_bodies()
	var player_found = false
	for b in bodies:
		if b.is_in_group("player"):
			player_found = true
			break
			
	if player_found and not _player_inside:
		_set_player_captured(true)
	elif not player_found and _player_inside:
		_set_player_captured(false)

func _set_player_captured(captured: bool) -> void:
	_player_inside = captured
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		if captured:
			player.call("add_capture")
		else:
			player.call("remove_capture")

func _draw() -> void:
	var points := PackedVector2Array([
		Vector2(-beam_width_top * 0.5, 0),
		Vector2(beam_width_top * 0.5, 0),
		Vector2(beam_width_bottom * 0.5, beam_length),
		Vector2(-beam_width_bottom * 0.5, beam_length)
	])
	draw_colored_polygon(points, beam_color)
	draw_polyline(points + PackedVector2Array([points[0]]),
		Color(0.6, 1.0, 1.0, 0.7), 2.0)
