## SpawnManager.gd
## Spawna aliens e itens de forma procedural conforme a fase atual.
## Conecta ao sinal phase_changed do GameManager para ajustar as ondas.

extends Node

@export var alien_patroller_scene: PackedScene
@export var alien_capture_scene: PackedScene
@export var alien_shooter_scene: PackedScene
@export var item_scene: PackedScene

var _spawn_timer: float = 0.0
var _item_timer: float = 0.0
var _screen_size: Vector2
var _active: bool = false


func _ready() -> void:
	_screen_size = get_viewport().get_visible_rect().size
	GameManager.phase_changed.connect(_on_phase_changed)


func start() -> void:
	_active = true
	_spawn_timer = 0.0
	_item_timer = randf_range(2.0, 5.0)
	# Spawna aliens imediatamente no início da fase
	var count: int = GameManager.get_initial_alien_count()
	for i in range(count):
		await get_tree().create_timer(0.3 * i).timeout
		if _active:
			_spawn_alien()


func stop() -> void:
	_active = false


func _process(delta: float) -> void:
	if not _active:
		return

	_spawn_timer += delta
	_item_timer -= delta

	var interval: float = GameManager.get_spawn_interval()
	if _spawn_timer >= interval:
		_spawn_timer = 0.0
		_spawn_alien()

	if _item_timer <= 0.0:
		_item_timer = randf_range(6.0, 10.0)
		_spawn_item()


# ── Spawn de alien ────────────────────────────────────────────────────────────

func _spawn_alien() -> void:
	var phase := GameManager.phase
	var roll := randf()
	var scene: PackedScene

	if phase == 1:
		scene = alien_patroller_scene
	elif phase == 2:
		scene = alien_capture_scene if roll < 0.4 else alien_patroller_scene
	else:
		if roll < 0.33:
			scene = alien_patroller_scene
		elif roll < 0.66:
			scene = alien_capture_scene
		else:
			scene = alien_shooter_scene

	if scene == null:
		return

	# Limita o AlienCapture a apenas 1 na tela para agir como um "Mini-Boss" de perseguição
	if scene == alien_capture_scene:
		var capture_count: int = 0
		for child in get_parent().get_children():
			if child.name.begins_with("AlienCapture") and not child.is_queued_for_deletion():
				capture_count += 1
		if capture_count >= 1:
			scene = alien_patroller_scene

	var alien: Node2D = scene.instantiate()
	if scene == alien_capture_scene:
		alien.position = Vector2(randf_range(80, _screen_size.x - 80), -60)
	else:
		alien.position = _random_spawn_position()
	get_parent().add_child(alien)


func _random_spawn_position() -> Vector2:
	# Spawna nas laterais ou no topo (fora da área visível)
	var side := randi() % 3  # 0=topo, 1=esq, 2=dir
	match side:
		0:  # topo
			return Vector2(randf_range(60, _screen_size.x - 60), -60)
		1:  # esquerda
			return Vector2(-60, randf_range(60, _screen_size.y * 0.5))
		2:  # direita
			return Vector2(_screen_size.x + 60, randf_range(60, _screen_size.y * 0.5))
	return Vector2(_screen_size.x * 0.5, -60)


# ── Spawn de item ─────────────────────────────────────────────────────────────

func _spawn_item() -> void:
	if item_scene == null:
		return
	var item: Node2D = item_scene.instantiate()
	item.add_to_group("item")
	item.position = Vector2(randf_range(80, _screen_size.x - 80), -40)
	get_parent().add_child(item)


# ── Fase mudou ────────────────────────────────────────────────────────────────

func _on_phase_changed(_phase: int) -> void:
	# Reseta o timer ao mudar de fase
	_spawn_timer = 0.0
