extends Node

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause_game"):
		var parent = get_parent()
		if parent.has_method("_toggle_pause"):
			parent.call("_toggle_pause")
