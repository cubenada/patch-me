extends CharacterBody2D

enum State { IDLE, CHASE, AIM, RETURN, KNOCKBACK }

const SPEED := 65.0
const ACTIVATION_RADIUS := 200.0
const LEASH_RADIUS := 320.0
const ATTACK_RANGE := 120.0
const ATTACK_COOLDOWN := 0.67
const MAX_HP := 6
const HURTBOX_BROKEN_OFFSET := Vector2(-16.0, 0.0)
const DAMAGE_COOLDOWN := 1.5
const PROJECTILE := preload("res://scenes/enemies/ranged_projectile.tscn")
const DAMAGE_NUMBER := preload("res://scenes/ui/damage_number.tscn")
const PROJECTILE_SPAWN_OFFSET := Vector2(0.0, -8.0)

@onready var sprite: Sprite2D = $Sprite2D
@onready var damage_zone: Area2D = $DamageZone

var health: int = MAX_HP
var state: State = State.IDLE
var spawn_position: Vector2
var attack_timer: float = ATTACK_COOLDOWN
var contact_timer: float = 0.0
var player_in_zone: bool = false
var knockback_dir: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	spawn_position = global_position
	var hurt_box: Area2D = $HurtBox
	if not GameState.hitbox_accurate:
		hurt_box.position = HURTBOX_BROKEN_OFFSET
	damage_zone.body_entered.connect(_on_damage_zone_body_entered)
	damage_zone.body_exited.connect(_on_damage_zone_body_exited)

func _process(_delta: float) -> void:
	if velocity.length() > 0:
		sprite.position.y = sin(Time.get_ticks_msec() * 0.01) * 1.5
	else:
		sprite.position.y = 0.0

func _physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D

	match state:
		State.IDLE:
			velocity = Vector2.ZERO
			if player and global_position.distance_to(player.global_position) <= ACTIVATION_RADIUS:
				state = State.CHASE

		State.CHASE:
			var lost := not player \
				or global_position.distance_to(player.global_position) > ACTIVATION_RADIUS \
				or global_position.distance_to(spawn_position) > LEASH_RADIUS
			if lost:
				state = State.RETURN
			elif global_position.distance_to(player.global_position) <= ATTACK_RANGE:
				state = State.AIM
				attack_timer = ATTACK_COOLDOWN
			else:
				var dir := (player.global_position - global_position).normalized()
				velocity = dir * SPEED
				sprite.flip_h = dir.x < 0.0

		State.AIM:
			velocity = Vector2.ZERO
			if not player \
					or global_position.distance_to(player.global_position) > ACTIVATION_RADIUS \
					or global_position.distance_to(spawn_position) > LEASH_RADIUS:
				state = State.RETURN
			elif global_position.distance_to(player.global_position) > ATTACK_RANGE:
				state = State.CHASE
			else:
				sprite.flip_h = (player.global_position - global_position).x < 0.0
				attack_timer -= delta
				if attack_timer <= 0.0:
					_fire(player)
					attack_timer = ATTACK_COOLDOWN

		State.RETURN:
			var dir := (spawn_position - global_position).normalized()
			velocity = dir * SPEED
			sprite.flip_h = dir.x < 0.0
			if global_position.distance_to(spawn_position) < 8.0:
				global_position = spawn_position
				velocity = Vector2.ZERO
				state = State.IDLE

		State.KNOCKBACK:
			knockback_timer -= delta
			velocity = knockback_dir * (knockback_timer / 0.15) * 180.0
			if knockback_timer <= 0.0:
				state = State.CHASE

	move_and_slide()

	if contact_timer > 0.0:
		contact_timer -= delta
	elif player_in_zone:
		var p := get_tree().get_first_node_in_group("player") as Node2D
		if p:
			p.call("take_damage", 1)
			contact_timer = DAMAGE_COOLDOWN

func _on_damage_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_zone = true
		if contact_timer <= 0.0:
			body.call("take_damage", 1)
			contact_timer = DAMAGE_COOLDOWN

func _on_damage_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_zone = false

func _fire(player: Node2D) -> void:
	AudioManager.play("attack")
	var proj := PROJECTILE.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_position = global_position + PROJECTILE_SPAWN_OFFSET
	proj.direction = (player.global_position - proj.global_position).normalized()

func take_damage(amount: int) -> void:
	health -= amount
	queue_redraw()
	_flash_red()
	_spawn_damage_number(amount)
	if health <= 0:
		AudioManager.play("enemy_die")
		queue_free()

func _spawn_damage_number(amount: int) -> void:
	var num := DAMAGE_NUMBER.instantiate()
	get_tree().current_scene.add_child(num)
	num.global_position = global_position + Vector2(0.0, -26.0)
	num.setup(amount)

func _flash_red() -> void:
	sprite.modulate = Color(1.0, 0.15, 0.15)
	await get_tree().create_timer(0.15).timeout
	if is_instance_valid(sprite):
		sprite.modulate = Color.WHITE

func knockback(dir: Vector2) -> void:
	knockback_dir = dir
	knockback_timer = 0.15
	state = State.KNOCKBACK

func _draw() -> void:
	var w := 28.0
	var h := 4.0
	var y := -16.0
	var ratio := clampf(float(health) / float(MAX_HP), 0.0, 1.0)
	draw_rect(Rect2(-w / 2.0 - 1.0, y - 1.0, w + 2.0, h + 2.0), Color(0, 0, 0, 0.8))
	draw_rect(Rect2(-w / 2.0, y, w, h), Color(0.15, 0.15, 0.15))
	draw_rect(Rect2(-w / 2.0, y, w * ratio, h), Color(0.2, 0.5, 0.85))
