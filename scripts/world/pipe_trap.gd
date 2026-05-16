extends Node2D

const PIPE_PROJECTILE := preload("res://scenes/world/pipe_projectile.tscn")
const COOLDOWN := 1.2
const DETECT_RANGE := 120.0
const SIDE_TOLERANCE := 14.0

var direction: Vector2 = Vector2.RIGHT
var _cooldown_timer: float = 0.0

func configure(shoot_direction: Vector2) -> void:
	direction = shoot_direction

func _physics_process(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta
		return
	if _is_player_in_front():
		_fire()
		_cooldown_timer = COOLDOWN

func _is_player_in_front() -> bool:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return false
	var to_player: Vector2 = player.global_position - global_position
	var forward: float = to_player.dot(direction)
	if forward <= 0.0 or forward > DETECT_RANGE:
		return false
	var perp: Vector2 = Vector2(-direction.y, direction.x)
	return absf(to_player.dot(perp)) <= SIDE_TOLERANCE

func _fire() -> void:
	var proj := PIPE_PROJECTILE.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_position = global_position + direction * 8.0
	proj.direction = direction
	AudioManager.play("attack_w0")
