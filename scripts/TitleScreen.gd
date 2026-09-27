## TitleScreen.gd
## Tela inicial com animação de UFO voando, título e botão de início.

extends Node2D

@onready var ufo_sprite: Node2D      = $UFOSprite
@onready var start_label: Label      = $UILayer/UI/StartLabel
@onready var high_score_label: Label = $UILayer/UI/HighScoreLabel

var _ufo_timer: float = 0.0
var _blink_timer: float = 0.0
var _blink_on: bool = true


func _ready() -> void:
	high_score_label.text = "RECORDE: %06d" % GameManager.high_score
	# Anima o UFO cruzando a tela da esquerda para a direita em loop
	var screen_w: float = get_viewport_rect().size.x
	var tween := create_tween().set_loops()
	tween.tween_property(ufo_sprite, "position:x",
		screen_w + 120.0, 4.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(ufo_sprite, "position:x",
		-120.0, 0.0)  # reset instantâneo


func _process(delta: float) -> void:
	_ufo_timer += delta
	# Bob vertical suave do UFO
	ufo_sprite.position.y = 160.0 + sin(_ufo_timer * 2.0) * 20.0

	# Pisca o label "PRESSIONE ENTER"
	_blink_timer += delta
	if _blink_timer >= 0.5:
		_blink_timer = 0.0
		_blink_on = not _blink_on
		start_label.modulate.a = 1.0 if _blink_on else 0.25

	# Qualquer tecla de confirmação inicia o jogo
	if Input.is_action_just_pressed("ui_accept") \
	or Input.is_key_pressed(KEY_ENTER) \
	or Input.is_key_pressed(KEY_SPACE):
		_start_game()


func _start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
