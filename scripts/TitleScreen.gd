## TitleScreen.gd
## Tela inicial com animação de UFO voando, título e botão de início.

extends Node2D

@onready var ufo_sprite: Node2D      = $UFOSprite
@onready var start_label: Label      = $UILayer/UI/StartLabel
@onready var high_score_label: Label = $UILayer/UI/HighScoreLabel
@onready var title_label: Label      = $UILayer/UI/TitleLabel
@onready var bg_rect: ColorRect      = $UILayer/UI/BGRect
@onready var credits_label: Label    = $UILayer/UI/CreditsLabel

var _ufo_timer: float = 0.0
var _blink_timer: float = 0.0
var _blink_on: bool = true

func _ready() -> void:
	# Ocultar o texto cinza na parte inferior
	if credits_label:
		credits_label.visible = false

	# Remover emojis do título e adicionar sombra
	title_label.text = "ALIEN DROP ZONE"
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	title_label.add_theme_constant_override("shadow_offset_x", 3)
	title_label.add_theme_constant_override("shadow_offset_y", 3)

	# Fundo do espaço
	var bg_tex = Image.new()
	if bg_tex.load("res://assets/backgrounds/space_bg.png") == OK:
		var tex_rect = TextureRect.new()
		tex_rect.texture = ImageTexture.create_from_image(bg_tex)
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		tex_rect.modulate = Color(0.12, 0.12, 0.18, 1.0)
		bg_rect.get_parent().add_child(tex_rect)
		bg_rect.get_parent().move_child(tex_rect, 0)
		bg_rect.queue_free()

	# Substituir polígonos por arte HD
	for child in ufo_sprite.get_children():
		child.queue_free()
		
	var spr = Sprite2D.new()
	var img = Image.new()
	if img.load("res://assets/sprites/alien_shooter.png") == OK:
		img.generate_mipmaps()
		spr.texture = ImageTexture.create_from_image(img)
	spr.scale = Vector2(0.16, 0.16)
	ufo_sprite.add_child(spr)

	high_score_label.text = "RECORDE: %06d" % GameManager.high_score
	
	# Anima o UFO cruzando a tela
	var screen_w: float = get_viewport_rect().size.x
	var tween := create_tween().set_loops()
	tween.tween_property(ufo_sprite, "position:x",
		screen_w + 120.0, 4.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(ufo_sprite, "position:x",
		-120.0, 0.0)


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
