## GameOver.gd
## Tela de fim de jogo.

extends Node2D

@onready var final_score_label: Label  = $UILayer/UI/FinalScoreLabel
@onready var high_score_label: Label   = $UILayer/UI/HighScoreLabel
@onready var new_record_label: Label   = $UILayer/UI/NewRecordLabel
@onready var alien_face: Node2D        = $AlienFace


func _ready() -> void:
	final_score_label.text = "PONTUAÇÃO FINAL\n%06d" % GameManager.score
	high_score_label.text  = "RECORDE: %06d" % GameManager.high_score
	new_record_label.visible = (GameManager.score > 0 and GameManager.score >= GameManager.high_score)

	# Animação de entrada: fade in
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8)

	# Animação do rosto alien: pulso suave
	var face_tween := create_tween().set_loops()
	face_tween.tween_property(alien_face, "scale",
		Vector2(1.06, 1.06), 0.9).set_ease(Tween.EASE_IN_OUT)
	face_tween.tween_property(alien_face, "scale",
		Vector2(1.0, 1.0), 0.9).set_ease(Tween.EASE_IN_OUT)


func _on_retry_button_pressed() -> void:
	GameManager.start_new_game()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/TitleScreen.tscn")
