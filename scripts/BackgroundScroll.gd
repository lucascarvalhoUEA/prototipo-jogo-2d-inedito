## BackgroundScroll.gd
## Fundo estrelado gerado proceduralmente com parallax.
## Cria camadas de estrelas em diferentes tamanhos e velocidades.

extends Node2D

const STAR_COUNT := 80
const CLOUD_COUNT := 6

var _stars: Array[Dictionary] = []
var _clouds: Array[Dictionary] = []
var _scroll_y: float = 0.0
var _screen: Vector2


func _ready() -> void:
	_screen = get_viewport_rect().size
	_generate_stars()
	_generate_clouds()


func _generate_stars() -> void:
	for i in range(STAR_COUNT):
		_stars.append({
			"pos": Vector2(randf() * _screen.x, randf() * _screen.y),
			"size": randf_range(1.0, 3.0),
			"speed": randf_range(0.3, 1.0),
			"color": Color(randf_range(0.7, 1.0), randf_range(0.7, 1.0), 1.0, randf_range(0.5, 1.0))
		})


func _generate_clouds() -> void:
	for i in range(CLOUD_COUNT):
		_clouds.append({
			"pos": Vector2(randf() * _screen.x, randf() * _screen.y),
			"width": randf_range(80, 180),
			"speed": randf_range(40.0, 80.0),
			"alpha": randf_range(0.05, 0.15)
		})


func _process(delta: float) -> void:
	_scroll_y += 60.0 * delta
	# Move estrelas para baixo (ilusão de queda)
	for star in _stars:
		star["pos"].y += star["speed"] * 60.0 * delta
		if star["pos"].y > _screen.y:
			star["pos"].y = 0.0
			star["pos"].x = randf() * _screen.x
	# Move nuvens
	for cloud in _clouds:
		cloud["pos"].y += cloud["speed"] * delta
		if cloud["pos"].y > _screen.y + 100:
			cloud["pos"].y = -100.0
			cloud["pos"].x = randf() * _screen.x
	queue_redraw()


func _draw() -> void:
	# Gradiente de fundo (céu → terra)
	var progress: float = clamp(_scroll_y / 2000.0, 0.0, 1.0)
	var sky_color: Color = Color(0.02, 0.02, 0.12, 1).lerp(Color(0.4, 0.6, 0.9, 1), progress)
	draw_rect(Rect2(Vector2.ZERO, _screen), sky_color)

	# Estrelas (só visíveis quando no espaço/alta altitude)
	var star_alpha: float = 1.0 - progress
	for star in _stars:
		var col: Color = star["color"]
		col.a *= star_alpha
		if col.a > 0.05:
			draw_circle(star["pos"], star["size"], col)

	# Nuvens (só visíveis quando em baixa altitude)
	var cloud_alpha: float = progress
	for cloud in _clouds:
		var col := Color(1, 1, 1, cloud["alpha"] * cloud_alpha * 2.0)
		_draw_cloud_ellipse(cloud["pos"], Vector2(cloud["width"], 30), col)


func _draw_cloud_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var nb_points := 24
	var pts := PackedVector2Array()
	for i in range(nb_points + 1):
		var angle_point := i * TAU / nb_points
		pts.append(center + Vector2(cos(angle_point) * radii.x, sin(angle_point) * radii.y))
	draw_colored_polygon(pts, color)
