## ItemPickup.gd
## Item coletável que cai da parte superior da tela.
## Tipo sorteado ao instanciar.

extends Area2D

enum ItemType { MEDKIT, BOOST, SHIELD, BOMB, STAR }

var item_type: ItemType = ItemType.STAR
var _fall_speed: float = 90.0
var _bob_timer: float = 0.0

# Mapeamento tipo → cor e label (usando chaves int explícitas)
const TYPE_DATA: Dictionary = {
	0: { "color": Color(0.2, 0.9, 0.3), "icon": "💊", "label": "+VIDA" },   # MEDKIT
	1: { "color": Color(1.0, 0.8, 0.1), "icon": "⚡", "label": "TURBO" },  # BOOST
	2: { "color": Color(0.3, 0.6, 1.0), "icon": "🛡", "label": "ESCUDO" }, # SHIELD
	3: { "color": Color(0.9, 0.5, 0.1), "icon": "💣", "label": "BOMBA!" },  # BOMB
	4: { "color": Color(1.0, 1.0, 0.2), "icon": "⭐", "label": "+500" },   # STAR
}


func _ready() -> void:
	item_type = ItemType.values()[randi() % ItemType.size()] as ItemType
	_update_visual()
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	position.y += _fall_speed * delta
	_bob_timer += delta
	rotation = sin(_bob_timer * 2.0) * 0.15
	if position.y > get_viewport_rect().size.y + 60.0:
		queue_free()


func _update_visual() -> void:
	var key: int = int(item_type)
	var data: Dictionary = TYPE_DATA[key]
	var lbl: Label = $Label
	var glow: Polygon2D = $GlowRect
	lbl.text = data["icon"]
	glow.color = data["color"]
	
	# Load specific sprites for powerups
	var sprite_path = ""
	match item_type:
		ItemType.MEDKIT: sprite_path = "res://assets/sprites/powerup_medkit.png"
		ItemType.BOOST: sprite_path = "res://assets/sprites/powerup_speed.png"
		ItemType.SHIELD: sprite_path = "res://assets/sprites/powerup_shield.png"
		ItemType.BOMB: sprite_path = "res://assets/sprites/powerup_bomb.png"
		ItemType.STAR: sprite_path = "res://assets/sprites/powerup_star.png"
		
	if sprite_path != "":
		var img = Image.new()
		if img.load(sprite_path) == OK:
			img.generate_mipmaps()
			var spr = Sprite2D.new()
			spr.texture = ImageTexture.create_from_image(img)
			spr.scale = Vector2(0.06, 0.06)
			add_child(spr)
			lbl.visible = false
			glow.visible = false


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	_apply_effect(body)
	_show_pickup_text()
	queue_free()


func _apply_effect(player: Node) -> void:
	match item_type:
		ItemType.MEDKIT:
			GameManager.gain_life()
		ItemType.BOOST:
			player.call("activate_speed_boost", 2.0, 5.0)
		ItemType.SHIELD:
			player.call("activate_shield")
		ItemType.BOMB:
			var game = get_tree().current_scene
			if game.has_method("_clear_enemies"):
				game.call("_clear_enemies")
		ItemType.STAR:
			GameManager.add_score(500)


func _show_pickup_text() -> void:
	var key: int = int(item_type)
	var data: Dictionary = TYPE_DATA[key]
	var lbl := Label.new()
	lbl.text = data["label"]
	lbl.add_theme_color_override("font_color", data["color"] as Color)
	lbl.position = global_position + Vector2(-30, -20)
	get_tree().current_scene.add_child(lbl)
	var tween := lbl.create_tween()
	tween.tween_property(lbl, "position:y", lbl.position.y - 50.0, 0.8)
	tween.parallel().tween_property(lbl, "modulate:a", 0.0, 0.8)
	tween.tween_callback(lbl.queue_free)
