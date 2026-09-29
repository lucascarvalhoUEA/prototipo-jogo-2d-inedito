## Effects.gd
## Helpers estáticos para efeitos visuais rápidos ("game feel").
## Não é autoload: chame como `Effects.spawn_burst(...)` graças ao class_name.

extends Node
class_name Effects


## Cria uma explosão de partículas de disparo único (one-shot) e se autodestrói.
static func spawn_burst(parent: Node, global_pos: Vector2, color: Color,
		amount: int = 16, speed: float = 220.0, lifetime: float = 0.6) -> void:
	var p := CPUParticles2D.new()
	parent.add_child(p)
	p.global_position = global_pos
	p.amount = amount
	p.lifetime = lifetime
	p.one_shot = true
	p.explosiveness = 1.0
	p.spread = 180.0
	p.initial_velocity_min = speed * 0.4
	p.initial_velocity_max = speed
	p.gravity = Vector2(0, 200)
	p.scale_amount_min = 2.0
	p.scale_amount_max = 4.0
	p.color = color
	p.emitting = true

	await parent.get_tree().create_timer(lifetime + 0.2).timeout
	if is_instance_valid(p):
		p.queue_free()
