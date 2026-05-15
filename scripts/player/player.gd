extends CharacterBody2D

const SPEED := 180.0
const DASH_FORCE := 400.0
const DASH_DURATION := 0.15
const MAX_HEALTH := 4
const PROJECTILE := preload("res://scenes/player/projectile.tscn")
const PAUSE_MENU := preload("res://scenes/world/pause_menu.tscn")
const ICE_BALL := preload("res://scenes/player/ice_ball.tscn")

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var health: int = MAX_HEALTH
var on_high_ground: bool = false
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var can_attack: bool = true
var attack_cooldown_timer: float = 0.0
var last_direction := Vector2.RIGHT
var last_move_direction := Vector2.RIGHT

func _ready() -> void:
	add_to_group("player")
	if not GameState.hitbox_accurate:
		collision_shape.position = Vector2(10.0, 5.0)
	if GameState.is_loading_save:
		global_position = GameState.saved_player_pos
		health = GameState.saved_player_health
		GameState.is_loading_save = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		GameState.save_game(get_tree().current_scene.scene_file_path, global_position, health)
		get_tree().current_scene.add_child(PAUSE_MENU.instantiate())

func _process(_delta: float) -> void:
	if velocity.length() > 0:
		sprite.position.y = sin(Time.get_ticks_msec() * 0.008) * 2.0
	else:
		sprite.position.y = 0.0

func _physics_process(delta: float) -> void:
	_handle_weapon_select()
	_handle_dash(delta)
	_handle_movement()
	_handle_attack(delta)
	move_and_slide()

func _handle_movement() -> void:
	if is_dashing:
		return
	var direction := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	velocity = direction * SPEED
	if direction != Vector2.ZERO:
		last_move_direction = direction
	var aim := (get_global_mouse_position() - global_position)
	if aim.length() > 1.0:
		last_direction = aim.normalized()
	sprite.flip_h = last_direction.x < 0.0

func _handle_dash(delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer <= 0.0:
		is_dashing = true
		dash_timer = DASH_DURATION
		dash_cooldown_timer = 0.5
		velocity = last_move_direction * DASH_FORCE
		AudioManager.play("dash")
		_start_dash_visual()

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			_end_dash_visual()

func _handle_attack(delta: float) -> void:
	if not can_attack:
		attack_cooldown_timer -= delta
		if attack_cooldown_timer <= 0.0:
			can_attack = true
		return

	var fired := false
	if GameState.current_weapon == 2:
		fired = Input.is_action_pressed("attack")
	else:
		fired = Input.is_action_just_pressed("attack")

	if fired:
		can_attack = false
		match GameState.current_weapon:
			1: attack_cooldown_timer = 0.65
			2: attack_cooldown_timer = 0.1
			_: attack_cooldown_timer = 0.4
		if GameState.current_weapon != 2 and animation.has_animation("attack"):
			animation.play("attack")
		AudioManager.play("attack_w" + str(GameState.current_weapon))
		_fire_weapon()

func _handle_weapon_select() -> void:
	if Input.is_action_just_pressed("weapon_1") and GameState.weapons_unlocked[0]:
		GameState.current_weapon = 0
	elif Input.is_action_just_pressed("weapon_2") and GameState.weapons_unlocked[1]:
		GameState.current_weapon = 1
	elif Input.is_action_just_pressed("weapon_3") and GameState.weapons_unlocked[2]:
		GameState.current_weapon = 2

func _fire_weapon() -> void:
	if not GameState.weapons_unlocked[GameState.current_weapon]:
		return
	match GameState.current_weapon:
		0: _fire_projectile()
		1: _fire_shotgun()
		2: _fire_ice()

func _fire_projectile() -> void:
	var proj := PROJECTILE.instantiate()
	proj.direction = last_direction
	_apply_elevation_mask(proj)
	get_parent().add_child(proj)
	proj.global_position = global_position

func _fire_shotgun() -> void:
	var spread := deg_to_rad(22.0)
	for angle_offset in [-spread, 0.0, spread]:
		var proj := PROJECTILE.instantiate()
		proj.direction = last_direction.rotated(angle_offset)
		_apply_elevation_mask(proj)
		get_parent().add_child(proj)
		proj.global_position = global_position

func _fire_ice() -> void:
	var proj := ICE_BALL.instantiate()
	proj.direction = last_direction
	_apply_elevation_mask(proj)
	get_parent().add_child(proj)
	proj.global_position = global_position

func _apply_elevation_mask(proj: Area2D) -> void:
	if not on_high_ground:
		proj.collision_mask |= 16

func take_damage(amount: int) -> void:
	health -= amount
	queue_redraw()
	AudioManager.play("player_hurt")
	_flash_red()
	if health <= 0:
		get_tree().call_deferred("reload_current_scene")

func _draw() -> void:
	var w := 32.0
	var h := 4.0
	var y := -24.0
	var ratio := clampf(float(health) / float(MAX_HEALTH), 0.0, 1.0)
	draw_rect(Rect2(-w / 2.0 - 1.0, y - 1.0, w + 2.0, h + 2.0), Color(0, 0, 0, 0.8))
	draw_rect(Rect2(-w / 2.0, y, w, h), Color(0.15, 0.15, 0.15))
	draw_rect(Rect2(-w / 2.0, y, w * ratio, h), Color(0.2, 0.85, 0.3))

func _start_dash_visual() -> void:
	var h: float = abs(last_move_direction.x)
	var v: float = abs(last_move_direction.y)
	sprite.scale = Vector2(1.0 + h * 0.35 - v * 0.25, 1.0 - h * 0.3 + v * 0.4)
	sprite.modulate.a = 0.5

func _end_dash_visual() -> void:
	var tween := create_tween().set_parallel()
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.12)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.12)

func _flash_red() -> void:
	sprite.modulate = Color(1.0, 0.15, 0.15, 1.0)
	await get_tree().create_timer(0.2).timeout
	if is_instance_valid(sprite):
		sprite.modulate = Color.WHITE
