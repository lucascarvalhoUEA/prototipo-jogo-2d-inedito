## GameOver.gd
## Tela de fim de jogo.

extends Node2D

@onready var final_score_label: Label  = $UILayer/UI/FinalScoreLabel
@onready var high_score_label: Label   = $UILayer/UI/HighScoreLabel
@onready var new_record_label: Label   = $UILayer/UI/NewRecordLabel
@onready var bg_rect: ColorRect        = $UILayer/UI/BGRect
@onready var game_over_label: Label    = $UILayer/UI/GameOverLabel
@onready var retry_btn: Button         = $UILayer/UI/RetryButton
@onready var menu_btn: Button          = $UILayer/UI/MenuButton

func _ready() -> void:
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
		
		# Overlay escuro em cima do fundo para dar clima de derrota
		bg_rect.color = Color(0.05, 0.0, 0.1, 0.6)
	
	# Sombras de texto
	game_over_label.add_theme_color_override("font_shadow_color", Color(0.3, 0, 0, 1.0))
	game_over_label.add_theme_constant_override("shadow_offset_x", 4)
	game_over_label.add_theme_constant_override("shadow_offset_y", 4)
	
	final_score_label.text = "PONTUAÇÃO FINAL\n%06d" % GameManager.score
	high_score_label.text  = "RECORDE: %06d" % GameManager.high_score
	new_record_label.visible = (GameManager.score > 0 and GameManager.score >= GameManager.high_score)

	# Limpar Emojis
	retry_btn.text = "TENTAR NOVAMENTE"
	menu_btn.text = "MENU PRINCIPAL"

	# Arte na tela de Game Over
	var spr = Sprite2D.new()
	var img = Image.new()
	if img.load("res://assets/sprites/alien_capture.png") == OK:
		img.generate_mipmaps()
		spr.texture = ImageTexture.create_from_image(img)
	spr.scale = Vector2(0.2, 0.2)
	spr.position = Vector2(get_viewport_rect().size.x / 2.0, 240)
	$UILayer/UI.add_child(spr)

	# Animação de entrada: fade in
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8)


func _on_retry_button_pressed() -> void:
	GameManager.start_new_game()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/TitleScreen.tscn")
