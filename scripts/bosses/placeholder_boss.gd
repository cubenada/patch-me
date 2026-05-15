extends CharacterBody2D

enum Phase { IDLE, ONE, FREEZE, THREE, RETURN, DEAD }

const MAX_HP := 100
const MOVE_SPEED := 80.0
const FREEZE_DURATION := 2.0
const ACTIVATION_RADIUS := 320.0
const LEASH_RADIUS := 500.0
const HURTBOX_BROKEN_OFFSET := Vector2(36.0, -28.0)
const DAMAGE_COOLDOWN := 1.5
const ATTACK_RANGE := 250.0
const BOSS_PROJECTILE := preload("res://scenes/bosses/boss_projectile.tscn")
const PROJECTILE_SPAWN_OFFSET := Vector2(0.0, -80.0)

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_outline: Line2D = $HitboxOutline
@onready var hurt_box: Area2D = $HurtBox
@onready var damage_zone: Area2D = $DamageZone

var hp: int = MAX_HP
var phase: Phase = Phase.IDLE
var phase_before_return: Phase = Phase.ONE
var active: bool = true
var freeze_timer: float = 0.0
var attack_timer: float = 1.0
var contact_timer: float = 0.0
var player_in_zone: bool = false
var spawn_position: Vector2
var _is_attacking: bool = false

signal boss_defeated

func _ready() -> void:
	spawn_position = global_position
	hurt_box.area_entered.connect(_on_hurt_box_area_entered)
	damage_zone.body_entered.connect(_on_damage_zone_body_entered)
	damage_zone.body_exited.connect(_on_damage_zone_body_exited)
	anim.animation_finished.connect(_on_anim_finished)
	if not GameState.hitbox_accurate:
		hurt_box.position = HURTBOX_BROKEN_OFFSET
	hitbox_outline.visible = false
	anim.play("idle")

func _physics_process(delta: float) -> void:
	match phase:
		Phase.IDLE:   _phase_idle()
		Phase.ONE:    _phase_one(delta)
		Phase.FREEZE: _phase_freeze(delta)
		Phase.THREE:  _phase_three(delta)
		Phase.RETURN: _phase_return()
	if contact_timer > 0.0:
		contact_timer -= delta
	elif player_in_zone:
		var player := _get_player()
		if player:
			player.call("take_damage", 1)
			contact_timer = DAMAGE_COOLDOWN
	if not _is_attacking:
		_select_anim()

# --- Animation ----------------------------------------------------------------

func _on_anim_finished() -> void:
	if anim.animation == &"attack":
		_is_attacking = false

func _select_anim() -> void:
	match phase:
		Phase.DEAD:
			if anim.animation != &"defeat":
				anim.play("defeat")
		Phase.IDLE, Phase.FREEZE:
			anim.play("idle")
		_:
			if velocity.length() > 1.0:
				anim.play("walk")
			else:
				anim.play("idle")

# --- Phases -------------------------------------------------------------------

func _phase_idle() -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	if not active:
		return
	var player := _get_player()
	if player and global_position.distance_to(player.global_position) <= ACTIVATION_RADIUS:
		phase = Phase.ONE

func _phase_one(delta: float) -> void:
	if _should_leash():
		_start_return(Phase.ONE)
		return
	var player := _get_player()
	if player and global_position.distance_to(player.global_position) <= ATTACK_RANGE:
		velocity = Vector2.ZERO
		move_and_slide()
	else:
		_move_toward_player()
	attack_timer -= delta
	if attack_timer <= 0.0:
		_fire_projectile()
		attack_timer = 1.0

func _phase_freeze(delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	freeze_timer -= delta
	if freeze_timer <= 0.0:
		phase = Phase.THREE
		attack_timer = 0.8

func _phase_three(delta: float) -> void:
	if _should_leash():
		_start_return(Phase.THREE)
		return
	var player := _get_player()
	if player and global_position.distance_to(player.global_position) <= ATTACK_RANGE:
		velocity = Vector2.ZERO
		move_and_slide()
	else:
		_move_toward_player()
	attack_timer -= delta
	if attack_timer <= 0.0:
		_fire_spread()
		attack_timer = 0.6

func _phase_return() -> void:
	var dir := (spawn_position - global_position).normalized()
	velocity = dir * MOVE_SPEED
	move_and_slide()
	anim.flip_h = dir.x < 0.0
	if global_position.distance_to(spawn_position) < 10.0:
		global_position = spawn_position
		velocity = Vector2.ZERO
		phase = Phase.IDLE

func _should_leash() -> bool:
	var player := _get_player()
	if not player:
		return true
	return global_position.distance_to(player.global_position) > ACTIVATION_RADIUS \
		or global_position.distance_to(spawn_position) > LEASH_RADIUS

func _start_return(from_phase: Phase) -> void:
	phase_before_return = from_phase
	phase = Phase.RETURN

func _get_player() -> Node2D:
	return get_tree().get_first_node_in_group("player") as Node2D

func _move_toward_player() -> void:
	var player := _get_player()
	if not player:
		return
	var dir := (player.global_position - global_position).normalized()
	velocity = dir * MOVE_SPEED
	move_and_slide()
	anim.flip_h = dir.x < 0.0

func _fire_projectile() -> void:
	_is_attacking = true
	anim.play("attack")
	var player := _get_player()
	if not player:
		return
	AudioManager.play("attack")
	_spawn_projectile((player.global_position - (global_position + PROJECTILE_SPAWN_OFFSET)).normalized())

func _fire_spread() -> void:
	_is_attacking = true
	anim.play("attack")
	var player := _get_player()
	if not player:
		return
	AudioManager.play("attack")
	var base_dir := (player.global_position - (global_position + PROJECTILE_SPAWN_OFFSET)).normalized()
	var spread := deg_to_rad(18.0)
	for offset: float in [-spread, 0.0, spread]:
		_spawn_projectile(base_dir.rotated(offset))

func _spawn_projectile(dir: Vector2) -> void:
	var proj := BOSS_PROJECTILE.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_position = global_position + PROJECTILE_SPAWN_OFFSET
	proj.direction = dir

# --- Combat -------------------------------------------------------------------

func _on_damage_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_zone = true
		if contact_timer <= 0.0:
			body.call("take_damage", 1)
			contact_timer = DAMAGE_COOLDOWN

func _on_damage_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_zone = false

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		take_damage(1)

func take_damage(amount: int) -> void:
	if phase == Phase.DEAD or not active:
		return
	hp -= amount
	queue_redraw()
	AudioManager.play("boss_hit")
	_check_phase_transition()

func _check_phase_transition() -> void:
	var pct := float(hp) / MAX_HP
	if pct <= 0.0:
		_die()
	elif pct <= 0.5 and phase == Phase.ONE:
		phase = Phase.FREEZE
		freeze_timer = FREEZE_DURATION
		velocity = Vector2.ZERO
	elif pct <= 0.25 and phase == Phase.FREEZE:
		phase = Phase.THREE

func _draw() -> void:
	if phase == Phase.IDLE or phase == Phase.DEAD:
		return
	var w := 72.0
	var h := 6.0
	var y := -92.0
	var ratio := clampf(float(hp) / float(MAX_HP), 0.0, 1.0)
	draw_rect(Rect2(-w / 2.0 - 1.0, y - 1.0, w + 2.0, h + 2.0), Color(0, 0, 0, 0.8))
	draw_rect(Rect2(-w / 2.0, y, w, h), Color(0.15, 0.15, 0.15))
	draw_rect(Rect2(-w / 2.0, y, w * ratio, h), Color(0.85, 0.15, 0.15))

func _die() -> void:
	phase = Phase.DEAD
	velocity = Vector2.ZERO
	_is_attacking = false
	anim.play("defeat")
	AudioManager.play("boss_die")
	await get_tree().create_timer(1.5).timeout
	boss_defeated.emit()
	queue_free()
