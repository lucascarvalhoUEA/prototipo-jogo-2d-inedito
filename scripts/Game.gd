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
	GameManager.start_new_game()
	_setup_landing_zone()
	_start_phase()


func _process(delta: float) -> void:
	if not _game_running:
		return
	if Input.is_action_just_pressed("pause_game"):
		_toggle_pause()

	# Detecta paraquedista saindo pela base da tela (falhou no pouso)
	var screen_h: float = get_viewport_rect().size.y
	if player.position.y > screen_h + 80.0 and not _handling_phase:
		_on_player_fell_off()


# ── Fase ──────────────────────────────────────────────────────────────────────

func _start_phase() -> void:
	_game_running = true
	_handling_phase = false
	spawn_manager.call("start")
	_show_phase_banner("FASE  %d" % GameManager.phase)
	_update_landing_zone_width()


func _setup_landing_zone() -> void:
	var vp: Rect2 = get_viewport_rect()
	landing_zone.position = Vector2(vp.size.x * 0.5, vp.size.y - LANDING_ZONE_Y_OFFSET)
	_update_landing_zone_width()
	# NÃO conectar aqui — a conexão já está no arquivo .tscn


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


# ── Saiu da tela pelo fundo (errou o pouso) ───────────────────────────────────

func _on_player_fell_off() -> void:
	_handling_phase = true
	_game_running = false
	spawn_manager.call("stop")
	GameManager.lose_life()

	# Se ainda tem vidas, respawna na próxima fase
	if GameManager.lives > 0:
		_show_feedback("PERDEU UMA VIDA!", Color.RED)
		await get_tree().create_timer(1.5).timeout
		
		# Desativa a zona de pouso durante o teletransporte
		var area: Area2D = landing_zone.get_node("Area2D")
		area.monitoring = false
		
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
	# Remove aliens existentes
	for child in get_children():
		if child.is_in_group("alien"):
			child.queue_free()
	
	# Desativa a zona de pouso temporariamente para evitar colisão falsa do respawn
	var area: Area2D = landing_zone.get_node("Area2D")
	area.monitoring = false
	
	_reset_player_position()
	_update_landing_zone_width()
	
	# Espera o motor físico atualizar a nova posição do jogador
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	area.monitoring = true
	_start_phase()


func _reset_player_position() -> void:
	var vp: Rect2 = get_viewport_rect()
	player.position = Vector2(vp.size.x * 0.5, 80.0)
	player.velocity = Vector2.ZERO
	player.set("is_landed", false)
	player.set("is_dead", false)
	player.set("is_captured", false)
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
