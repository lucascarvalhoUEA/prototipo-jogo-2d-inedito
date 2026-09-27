## LandingZone.gd
## Plataforma de pouso que pisca e detecta o paraquedista.
## Emite player_landed(speed) ao detectar o jogador com velocidade descendente.

extends Node2D

signal player_landed(speed: float)

@export var zone_height: float = 20.0
var zone_width: float = 300.0

var _blink_timer: float = 0.0
var _blink_on: bool = true
var _player_on_zone: bool = false


func _ready() -> void:
	_rebuild_collision()


func set_width(new_width: float) -> void:
	zone_width = new_width
	_rebuild_collision()
	queue_redraw()


func _rebuild_collision() -> void:
	var col: CollisionShape2D = $Area2D/CollisionShape2D
	if not col.shape is RectangleShape2D:
		col.shape = RectangleShape2D.new()
	col.shape.size = Vector2(zone_width, zone_height)


func _process(delta: float) -> void:
	# Pisca
	_blink_timer += delta
	if _blink_timer >= 0.4:
		_blink_timer = 0.0
		_blink_on = not _blink_on
		queue_redraw()


func _draw() -> void:
	var col: Color = Color(0.2, 1.0, 0.4, 0.9) if _blink_on else Color(0.1, 0.6, 0.2, 0.5)
	var rect := Rect2(-zone_width * 0.5, -zone_height * 0.5, zone_width, zone_height)
	draw_rect(rect, col, true)
	draw_rect(rect, Color.WHITE, false, 2.0)

	# Seta indicadora (acima da zona)
	var arrow_y: float = -zone_height * 0.5 - 30.0
	var pts := PackedVector2Array([
		Vector2(0, arrow_y + 20),
		Vector2(-12, arrow_y),
		Vector2(12, arrow_y),
	])
	draw_colored_polygon(pts, Color(0.2, 1.0, 0.4, 0.8 if _blink_on else 0.3))

	# Texto "POUSE AQUI"
	draw_string(ThemeDB.fallback_font,
		Vector2(-45, -zone_height * 0.5 - 42),
		"POUSE AQUI",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1, 14,
		Color(1, 1, 1, 0.9 if _blink_on else 0.4))


func _on_area_2d_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not _player_on_zone:
		var cb := body as CharacterBody2D
		if cb == null:
			return
		var speed: float = absf(cb.velocity.y)
		if speed > 10.0:
			_player_on_zone = true
			cb.call("land", speed)
			emit_signal("player_landed", speed)


func reset() -> void:
	_player_on_zone = false
