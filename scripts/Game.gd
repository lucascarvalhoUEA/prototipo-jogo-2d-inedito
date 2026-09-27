## Game.gd
## Controlador da cena principal de jogo.

extends Node2D

const LANDING_ZONE_Y_OFFSET: float = 80.0
const PHASE_SCORE_BONUS: int = 300

@onready var player: CharacterBody2D   = $Parachuter
@onready var spawn_manager: Node       = $SpawnManager
@onready var landing_zone: Node2D      = $LandingZone
@onready var pause_overlay: CanvasLayer = $PauseOverlay
@onready var phase_banner: Label       = $HUD/PhaseBanner

var _game_running: bool = false
var _paused: bool = false
var _handling_phase: bool = false   # guarda para evitar chamadas duplas


func _ready() -> void:
	GameManager.game_over.connect(_on_game_over)
	GameManager.phase_complete.connect(_on_phase_complete)
	player.hit_by_alien.connect(_on_player_hit_by_alien)
	GameManager.start_new_game()
	_setup_landing_zone()
	
	var p_handler = Node.new()
	p_handler.name = "PauseHandler"
	p_handler.process_mode = Node.PROCESS_MODE_ALWAYS
	p_handler.set_script(preload("res://scripts/PauseHandler.gd"))
	add_child(p_handler)
	
	_start_phase()


func _process(delta: float) -> void:
	if not _game_running:
		return

	# Detecta paraquedista saindo pela base da tela (falhou no pouso)
	var screen_h: float = get_viewport_rect().size.y
	if player.position.y > screen_h + 80.0 and not _handling_phase:
		_handle_life_lost("PASSOU DIRETO!")


# ── Fase ──────────────────────────────────────────────────────────────────────

func _start_phase() -> void:
	_game_running = true
	_handling_phase = false
	spawn_manager.call("start")
	_show_phase_banner("FASE  %d" % GameManager.phase)
	_update_landing_zone_width()


func _setup_landing_zone() -> void:
	_update_landing_zone_width()
	_randomize_landing_zone()


func _randomize_landing_zone() -> void:
	var vp: Rect2 = get_viewport_rect()
	var zone_w: float = GameManager.get_landing_zone_width()
	# Randomiza o X entre as bordas, deixando uma margem de segurança
	var min_x: float = zone_w * 0.5 + 40.0
	var max_x: float = vp.size.x - (zone_w * 0.5) - 40.0
	var random_x: float = randf_range(min_x, max_x)
	landing_zone.position = Vector2(random_x, vp.size.y - LANDING_ZONE_Y_OFFSET)


func _update_landing_zone_width() -> void:
	landing_zone.call("set_width", GameManager.get_landing_zone_width())


func _show_phase_banner(text: String) -> void:
	phase_banner.text = text
	phase_banner.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(phase_banner, "modulate:a", 0.0, 0.8)


# ── Pouso bem-sucedido ────────────────────────────────────────────────────────

func _on_player_landed(landing_speed: float) -> void:
	if _handling_phase:   # guard contra dupla chamada
		return
	_handling_phase = true
	_game_running = false
	spawn_manager.call("stop")

	# Se aterrissar rápido demais (esmagando o botão para baixo), espatifa e perde vida!
	if landing_speed > 250.0:
		_handle_life_lost("ESPATIFOU!")
		return

	var bonus: int
	if landing_speed < 160.0:
		bonus = 500
		_show_feedback("POUSO PERFEITO! +500", Color.GREEN)
	else:
		bonus = 200
		_show_feedback("POUSO DURO! +200", Color.YELLOW)
	GameManager.add_score(bonus + PHASE_SCORE_BONUS)

	await get_tree().create_timer(2.0).timeout
	GameManager.next_phase()


# ── Perda de vida (caiu pra fora ou foi atingido) ────────────────────────────

func _on_player_hit_by_alien() -> void:
	if _handling_phase:
		return
	_handle_life_lost("ATINGIDO!")


func _handle_life_lost(message: String) -> void:
	_handling_phase = true
	_game_running = false
	spawn_manager.call("stop")
	player.call("die")
	GameManager.lose_life()

	# Se ainda tem vidas, respawna na próxima fase
	if GameManager.lives > 0:
		_show_feedback(message, Color.RED)
		await get_tree().create_timer(1.5).timeout
		
		# Desativa a zona de pouso durante o teletransporte
		var area: Area2D = landing_zone.get_node("Area2D")
		area.monitoring = false
		
		_clear_enemies()
		_reset_player_position()
		
		await get_tree().physics_frame
		await get_tree().physics_frame
		
		area.monitoring = true
		_start_phase()
	# Se não tem vidas, o sinal game_over é emitido pelo GameManager


# ── Transição de fase ─────────────────────────────────────────────────────────

func _on_phase_complete() -> void:
	await get_tree().create_timer(0.5).timeout
	_reset_phase()


func _reset_phase() -> void:
	_clear_enemies()
	
	# Desativa a zona de pouso temporariamente para evitar colisão falsa do respawn
	var area: Area2D = landing_zone.get_node("Area2D")
	area.monitoring = false
	
	_reset_player_position()
	_update_landing_zone_width()
	_randomize_landing_zone()
	
	# Espera o motor físico atualizar a nova posição do jogador
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	area.monitoring = true
	_start_phase()


func _clear_enemies() -> void:
	for child in get_children():
		if child.is_in_group("alien") or child.is_in_group("projectile") or child.is_in_group("item"):
			child.queue_free()


func _reset_player_position() -> void:
	var vp: Rect2 = get_viewport_rect()
	player.position = Vector2(vp.size.x * 0.5, 80.0)
	player.velocity = Vector2.ZERO
	player.set("is_landed", false)
	player.set("is_dead", false)
	player.call("reset_capture")
	player.set("_blink_active", false)
	player.modulate.a = 1.0
	landing_zone.call("reset")   # limpa o flag de colisão para o próximo pouso


# ── Game Over ─────────────────────────────────────────────────────────────────

func _on_game_over() -> void:
	_game_running = false
	spawn_manager.call("stop")
	player.call("die")
	GameManager.end_game()
	await get_tree().create_timer(1.8).timeout
	get_tree().change_scene_to_file("res://scenes/menus/GameOver.tscn")


# ── Pausa ─────────────────────────────────────────────────────────────────────

func _toggle_pause() -> void:
	_paused = not _paused
	get_tree().paused = _paused
	pause_overlay.visible = _paused


# ── Feedback visual ───────────────────────────────────────────────────────────

func _show_feedback(text: String, color: Color) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 30)
	lbl.add_theme_color_override("font_color", color)
	var vp: Rect2 = get_viewport_rect()
	lbl.position = Vector2(vp.size.x * 0.5 - 160.0, vp.size.y * 0.5 - 20.0)
	$HUD.add_child(lbl)
	var tween := lbl.create_tween()
	tween.tween_property(lbl, "position:y", lbl.position.y - 70.0, 1.4)
	tween.parallel().tween_property(lbl, "modulate:a", 0.0, 1.4)
	tween.tween_callback(lbl.queue_free)
