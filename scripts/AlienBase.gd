## AlienBase.gd
## Classe base para todos os inimigos alien.
## Subclasses devem implementar _move(delta) e podem sobrescrever _on_body_entered.

extends CharacterBody2D
class_name AlienBase

signal alien_destroyed()

@export var base_speed: float = 150.0
@export var damage_on_contact: bool = true
@export var score_value: int = 100

var speed_multiplier: float = 1.0
var _player: CharacterBody2D = null


func _ready() -> void:
	speed_multiplier = GameManager.get_alien_speed_multiplier()
	await get_tree().process_frame
	var found: Node = get_tree().get_first_node_in_group("player")
	if found is CharacterBody2D:
		_player = found as CharacterBody2D
	_on_ready()


func _physics_process(delta: float) -> void:
	_move(delta)
	move_and_slide()
	
	if damage_on_contact:
		for i in get_slide_collision_count():
			var col: KinematicCollision2D = get_slide_collision(i)
			var collider: Node = col.get_collider() as Node
			if collider and collider.is_in_group("player"):
				collider.call("take_damage")


# ── Para sobrescrever nas subclasses ──────────────────────────────────────────

func _on_ready() -> void:
	pass


func _move(_delta: float) -> void:
	pass


# ── Colisão com jogador ───────────────────────────────────────────────────────

func _on_body_entered(body: Node) -> void:
	if damage_on_contact and body.is_in_group("player"):
		body.call("take_damage")


# ── Destruição ────────────────────────────────────────────────────────────────

func destroy() -> void:
	Effects.spawn_burst(get_tree().current_scene, global_position, Color(1.0, 0.6, 0.1), 20, 240.0, 0.6)
	GameManager.add_score(score_value)
	emit_signal("alien_destroyed")
	queue_free()


# ── Saiu da tela ─────────────────────────────────────────────────────────────

func _on_visible_on_screen_notifier_screen_exited() -> void:
	queue_free()
