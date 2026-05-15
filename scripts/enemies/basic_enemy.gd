extends CharacterBody2D

enum State { IDLE, CHASE, RETURN, COOLDOWN, KNOCKBACK }

const SPEED := 80.0
const ACTIVATION_RADIUS := 180.0
const LEASH_RADIUS := 300.0
const DAMAGE_COOLDOWN := 1.5
const CONTACT_DISTANCE := 14.0
const DAMAGE_ZONE_BROKEN_OFFSET := Vector2(50.0, 0.0)
const MAX_HP := 9

@onready var sprite: Sprite2D = $Sprite2D
@onready var damage_zone: Area2D = $DamageZone
@onready var hurt_box: Area2D = $HurtBox

var health: int = MAX_HP
var state: State = State.IDLE
var spawn_position: Vector2
var cooldown_timer: float = 0.0
var knockback_dir: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
var player_in_zone: bool = false

func _ready() -> void:
	spawn_position = global_position
	damage_zone.body_entered.connect(_on_damage_zone_body_entered)
	damage_zone.body_exited.connect(_on_damage_zone_body_exited)
	_apply_hitbox_state()
	if not GameState.hitbox_accurate:
		hurt_box.position = Vector2(-30.0, 0.0)

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
			else:
				var dist := global_position.distance_to(player.global_position)
				if dist > CONTACT_DISTANCE:
					var dir := (player.global_position - global_position).normalized()
					velocity = dir * SPEED
					sprite.flip_h = dir.x < 0.0
				else:
					velocity = Vector2.ZERO
				_apply_hitbox_state()

		State.RETURN:
			var dir := (spawn_position - global_position).normalized()
			velocity = dir * SPEED
			sprite.flip_h = dir.x < 0.0
			if global_position.distance_to(spawn_position) < 8.0:
				global_position = spawn_position
				velocity = Vector2.ZERO
				state = State.IDLE

		State.COOLDOWN:
			velocity = Vector2.ZERO
			cooldown_timer -= delta
			if cooldown_timer <= 0.0:
				if player_in_zone and player:
					player.call("take_damage", 1)
					cooldown_timer = DAMAGE_COOLDOWN
				else:
					var in_range := player and global_position.distance_to(player.global_position) <= ACTIVATION_RADIUS
					state = State.CHASE if in_range else State.IDLE

		State.KNOCKBACK:
			knockback_timer -= delta
			velocity = knockback_dir * (knockback_timer / 0.15) * 180.0
			if knockback_timer <= 0.0:
				state = State.CHASE

	move_and_slide()

func _apply_hitbox_state() -> void:
	if GameState.hitbox_accurate:
		damage_zone.position = Vector2.ZERO
	else:
		var facing := -1.0 if sprite.flip_h else 1.0
		damage_zone.position = DAMAGE_ZONE_BROKEN_OFFSET * facing

func _on_damage_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_zone = true
		body.call("take_damage", 1)
		state = State.COOLDOWN
		cooldown_timer = DAMAGE_COOLDOWN

func _on_damage_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_zone = false

func take_damage(amount: int) -> void:
	health -= amount
	queue_redraw()
	if health <= 0:
		AudioManager.play("enemy_die")
		queue_free()

func knockback(dir: Vector2) -> void:
	knockback_dir = dir
	knockback_timer = 0.15
	state = State.KNOCKBACK

func _draw() -> void:
	var w := 28.0
	var h := 4.0
	var y := -14.0
	var ratio := clampf(float(health) / float(MAX_HP), 0.0, 1.0)
	draw_rect(Rect2(-w / 2.0 - 1.0, y - 1.0, w + 2.0, h + 2.0), Color(0, 0, 0, 0.8))
	draw_rect(Rect2(-w / 2.0, y, w, h), Color(0.15, 0.15, 0.15))
	draw_rect(Rect2(-w / 2.0, y, w * ratio, h), Color(0.85, 0.4, 0.1))
