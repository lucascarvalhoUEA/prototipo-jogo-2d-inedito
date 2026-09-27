## Parachuter.gd
## O paraquedista controlado pelo jogador.
## Move-se horizontalmente com A/D ou setas.
## Segurar S / Espaço / Seta Baixo dobra o paraquedas (queda rápida).

extends CharacterBody2D

# ── Sinais ────────────────────────────────────────────────────────────────────
signal landed(speed: float)
signal hit_by_alien()
signal chute_folded(is_folded: bool)

# ── Parâmetros de movimento ───────────────────────────────────────────────────
@export var horizontal_speed: float = 320.0
@export var fall_speed_open: float = 140.0
@export var fall_speed_folded: float = 420.0
@export var tractor_pull_speed: float = 250.0

# ── Estado interno ────────────────────────────────────────────────────────────
var is_chute_folded: bool = false
var is_captured: bool = false
var _capture_count: int = 0
var is_dead: bool = false
var is_landed: bool = false
var shield_active: bool = false
var speed_boost: float = 1.0
var speed_boost_timer: float = 0.0

# ── Nós filhos ────────────────────────────────────────────────────────────────
# Usamos @onready com Node2D/Node para evitar erros se o nó não existir ainda
@onready var sprite_open: Node2D = $SpriteOpen
@onready var sprite_folded: Node2D = $SpriteFolded
@onready var damage_flash: ColorRect = $DamageFlash
@onready var shield_visual: Node2D = $ShieldVisual
@onready var invincibility_timer: Timer = $InvincibilityTimer

var _invincible: bool = false
var _blink_active: bool = false


func _ready() -> void:
	_update_sprite()
	invincibility_timer.timeout.connect(_on_invincibility_timer_timeout)


func _physics_process(delta: float) -> void:
	if is_dead or is_landed:
		return
	_handle_boost_timer(delta)
	_handle_horizontal()
	_handle_vertical()
	move_and_slide()
	_clamp_to_screen()
	_check_kinematic_collisions()


func _check_kinematic_collisions() -> void:
	for i in get_slide_collision_count():
		var col: KinematicCollision2D = get_slide_collision(i)
		var collider: Node = col.get_collider() as Node
		if collider and collider.is_in_group("alien"):
			var deals_damage = collider.get("damage_on_contact")
			if deals_damage != null and deals_damage == true:
				take_damage()


# ── Input horizontal ──────────────────────────────────────────────────────────

func _handle_horizontal() -> void:
	var dir: float = Input.get_axis("move_left", "move_right")
	velocity.x = dir * horizontal_speed * speed_boost


# ── Gravidade / vertical ──────────────────────────────────────────────────────

func _handle_vertical() -> void:
	if is_captured:
		velocity.y = -tractor_pull_speed
		return
	is_chute_folded = Input.is_action_pressed("fold_chute")
	_update_sprite()
	var target_fall: float = fall_speed_folded if is_chute_folded else fall_speed_open
	velocity.y = target_fall


# ── Boost de velocidade ───────────────────────────────────────────────────────

func _handle_boost_timer(delta: float) -> void:
	if speed_boost_timer > 0.0:
		speed_boost_timer -= delta
		if speed_boost_timer <= 0.0:
			speed_boost = 1.0


func activate_speed_boost(multiplier: float, duration: float) -> void:
	speed_boost = multiplier
	speed_boost_timer = duration


# ── Escudo ────────────────────────────────────────────────────────────────────

func activate_shield() -> void:
	shield_active = true
	shield_visual.visible = true


func deactivate_shield() -> void:
	shield_active = false
	shield_visual.visible = false


# ── Colisão com alien ─────────────────────────────────────────────────────────

func take_damage() -> void:
	if _invincible or is_dead or is_landed:
		return
	if shield_active:
		deactivate_shield()
		_flash_damage()
		_start_invincibility()
		return
	# Se não tem escudo, emite o sinal para o Game.gd resetar a fase
	emit_signal("hit_by_alien")
	_flash_damage()


func _flash_damage() -> void:
	damage_flash.visible = true
	await get_tree().create_timer(0.12).timeout
	damage_flash.visible = false


func _start_invincibility() -> void:
	_invincible = true
	invincibility_timer.start(1.5)
	_blink_sprite()


func _blink_sprite() -> void:
	if _blink_active:
		return
	_blink_active = true
	for i in range(6):
		modulate.a = 0.3
		await get_tree().create_timer(0.12).timeout
		modulate.a = 1.0
		await get_tree().create_timer(0.12).timeout
	_blink_active = false


func _on_invincibility_timer_timeout() -> void:
	_invincible = false
	modulate.a = 1.0


# ── Feixe de tração ───────────────────────────────────────────────────────────

func add_capture() -> void:
	_capture_count += 1
	is_captured = _capture_count > 0


func remove_capture() -> void:
	_capture_count = max(0, _capture_count - 1)
	is_captured = _capture_count > 0


func reset_capture() -> void:
	_capture_count = 0
	is_captured = false


# ── Pouso ─────────────────────────────────────────────────────────────────────

func land(landing_speed: float) -> void:
	if is_landed:
		return
	is_landed = true
	velocity = Vector2.ZERO
	emit_signal("landed", landing_speed)


# ── Morte ─────────────────────────────────────────────────────────────────────

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	# AnimationPlayer pode não ter animação 'death'; ignoramos se não existir
	var anim_player: AnimationPlayer = $AnimationPlayer
	if anim_player and anim_player.has_animation("death"):
		anim_player.play("death")


# ── Utilitários ───────────────────────────────────────────────────────────────

func _update_sprite() -> void:
	sprite_open.visible = not is_chute_folded
	sprite_folded.visible = is_chute_folded
	emit_signal("chute_folded", is_chute_folded)


func _clamp_to_screen() -> void:
	var vp: Rect2 = get_viewport_rect()
	var half_w: float = 20.0
	position.x = clamp(position.x, half_w, vp.size.x - half_w)
