## GameManager.gd
## Autoload Singleton — gerencia pontuação, vidas, fase atual e sinais globais.

extends Node

# Sinais globais
signal lives_changed(lives: int)
signal score_changed(score: int)
signal phase_changed(phase: int)
signal game_over()
signal phase_complete()

# Estado do jogo
var score: int = 0
var lives: int = 3
var phase: int = 1
var high_score: int = 0

const MAX_LIVES: int = 3
const LIVES_PER_PHASE_BONUS: int = 0  # sem bônus de vida automático por fase


func _ready() -> void:
	load_high_score()


# ── Pontuação ──────────────────────────────────────────────────────────────────

func add_score(points: int) -> void:
	score += points
	emit_signal("score_changed", score)


func reset_score() -> void:
	score = 0
	emit_signal("score_changed", score)


# ── Vidas ──────────────────────────────────────────────────────────────────────

func lose_life() -> void:
	lives -= 1
	lives = max(lives, 0)
	emit_signal("lives_changed", lives)
	if lives <= 0:
		emit_signal("game_over")


func gain_life() -> void:
	lives = min(lives + 1, MAX_LIVES)
	emit_signal("lives_changed", lives)


func reset_lives() -> void:
	lives = MAX_LIVES
	emit_signal("lives_changed", lives)


# ── Fases ──────────────────────────────────────────────────────────────────────

func next_phase() -> void:
	phase += 1
	emit_signal("phase_changed", phase)
	emit_signal("phase_complete")


func reset_phase() -> void:
	phase = 1
	emit_signal("phase_changed", phase)


# ── Novo jogo / Reinício ───────────────────────────────────────────────────────

func start_new_game() -> void:
	reset_score()
	reset_lives()
	reset_phase()


func end_game() -> void:
	if score > high_score:
		high_score = score
		save_high_score()


# ── Dificuldade por fase ───────────────────────────────────────────────────────

func get_alien_speed_multiplier() -> float:
	return 1.0 + (phase - 1) * 0.25  # +25% por fase


func get_spawn_interval() -> float:
	var base := 2.0
	return max(base - (phase - 1) * 0.2, 0.7)  # mínimo 0.7s


func get_initial_alien_count() -> int:
	# Aliens que aparecem imediatamente ao início da fase (máximo de 1 para evitar sobrecarga)
	return 1 if phase > 1 else 0


func get_landing_zone_width() -> float:
	var base := 300.0
	return max(base - (phase - 1) * 20.0, 120.0)  # mínimo 120px


# ── Persistência ──────────────────────────────────────────────────────────────

func save_high_score() -> void:
	var file := FileAccess.open("user://highscore.dat", FileAccess.WRITE)
	if file:
		file.store_32(high_score)
		file.close()


func load_high_score() -> void:
	if FileAccess.file_exists("user://highscore.dat"):
		var file := FileAccess.open("user://highscore.dat", FileAccess.READ)
		if file:
			high_score = file.get_32()
			file.close()
