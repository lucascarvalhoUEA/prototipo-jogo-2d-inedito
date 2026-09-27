## HUD.gd
## Interface do jogador: vidas (ícones de paraquedas), score, fase e aviso de feixe.

extends CanvasLayer

@onready var score_label: Label = $ScoreLabel
@onready var phase_label: Label = $PhaseLabel
@onready var lives_container: HBoxContainer = $LivesContainer
@onready var beam_warning: Label = $BeamWarning

var _beam_warning_timer: float = 0.0


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.phase_changed.connect(_on_phase_changed)
	_refresh_all()


func _process(delta: float) -> void:
	if _beam_warning_timer > 0.0:
		_beam_warning_timer -= delta
		beam_warning.modulate.a = abs(sin(_beam_warning_timer * 10.0))
	else:
		beam_warning.visible = false


func _refresh_all() -> void:
	_on_score_changed(GameManager.score)
	_on_lives_changed(GameManager.lives)
	_on_phase_changed(GameManager.phase)


func _on_score_changed(score: int) -> void:
	score_label.text = "PONTOS: %06d" % score


func _on_lives_changed(lives: int) -> void:
	# Limpa e recria os ícones de vida
	for child in lives_container.get_children():
		child.queue_free()
	for i in range(GameManager.MAX_LIVES):
		var icon := Label.new()
		icon.text = "🪂" if i < lives else "💀"
		icon.add_theme_font_size_override("font_size", 24)
		lives_container.add_child(icon)


func _on_phase_changed(phase: int) -> void:
	phase_label.text = "FASE %d" % phase


func show_beam_warning() -> void:
	beam_warning.visible = true
	_beam_warning_timer = 2.0
