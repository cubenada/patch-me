extends CharacterBody2D

enum Phase { IDLE, ONE, FREEZE, THREE, RETURN, DEAD }

const MAX_HP := 5
const MOVE_SPEED := 80.0
const FREEZE_DURATION := 5.0
const ATTACK_DAMAGE_OFFSET := Vector2(0.0, 0.0)
const ATTACK_DAMAGE_RADIUS := 62.0
const ACTIVATION_RADIUS := 320.0
const LEASH_RADIUS := 500.0
const HURTBOX_BROKEN_OFFSET := Vector2(36.0, -28.0)

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox_outline: Line2D = $HitboxOutline
@onready var hurt_box: Area2D = $HurtBox

var hp: int = MAX_HP
var phase: Phase = Phase.IDLE
var phase_before_return: Phase = Phase.ONE
var active: bool = true
var freeze_timer: float = 0.0
var attack_timer: float = 1.0
var spawn_position: Vector2

signal boss_defeated

func _ready() -> void:
	spawn_position = global_position
	hurt_box.area_entered.connect(_on_hurt_box_area_entered)
	if not GameState.hitbox_accurate:
		hurt_box.position = HURTBOX_BROKEN_OFFSET

func _physics_process(delta: float) -> void:
	match phase:
		Phase.IDLE:   _phase_idle()
		Phase.ONE:    _phase_one(delta)
		Phase.FREEZE: _phase_freeze(delta)
		Phase.THREE:  _phase_three(delta)
		Phase.RETURN: _phase_return()

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
	_move_toward_player()
	attack_timer -= delta
	if attack_timer <= 0.0:
		_attack_no_telegraph()
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
	_move_toward_player()
	attack_timer -= delta
	if attack_timer <= 0.0:
		_attack_with_hitbox_flash()
		attack_timer = 0.8

func _phase_return() -> void:
	var dir := (spawn_position - global_position).normalized()
	velocity = dir * MOVE_SPEED
	move_and_slide()
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

func _attack_no_telegraph() -> void:
	var player := _get_player()
	if not player:
		return
	var damage_origin := global_position + ATTACK_DAMAGE_OFFSET
	if damage_origin.distance_to(player.global_position) < ATTACK_DAMAGE_RADIUS:
		player.call("take_damage", 1)

func _attack_with_hitbox_flash() -> void:
	hitbox_outline.visible = true
	_attack_no_telegraph()
	await get_tree().create_timer(0.3).timeout
	hitbox_outline.visible = false

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		take_damage(1)

func take_damage(amount: int) -> void:
	if phase == Phase.DEAD:
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
	var y := -58.0
	var ratio := clampf(float(hp) / float(MAX_HP), 0.0, 1.0)
	draw_rect(Rect2(-w / 2.0 - 1.0, y - 1.0, w + 2.0, h + 2.0), Color(0, 0, 0, 0.8))
	draw_rect(Rect2(-w / 2.0, y, w, h), Color(0.15, 0.15, 0.15))
	draw_rect(Rect2(-w / 2.0, y, w * ratio, h), Color(0.85, 0.15, 0.15))

func _die() -> void:
	phase = Phase.DEAD
	velocity = Vector2.ZERO
	AudioManager.play("boss_die")
	hitbox_outline.position = Vector2.ZERO
	hitbox_outline.visible = true
	await get_tree().create_timer(1.5).timeout
	boss_defeated.emit()
	queue_free()
