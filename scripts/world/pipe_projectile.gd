extends Area2D

const SPEED := 220.0
const MAX_RANGE := 320.0
const GRACE_DISTANCE := 36.0

var direction: Vector2 = Vector2.RIGHT
var _distance: float = 0.0

func _ready() -> void:
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	var move: Vector2 = direction * SPEED * delta
	position += move
	_distance += move.length()
	if _distance >= GRACE_DISTANCE and collision_mask == 2:
		collision_mask = 3
	if _distance >= MAX_RANGE:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.call("take_damage", 99)
		queue_free()
	elif not (body is CharacterBody2D):
		queue_free()
