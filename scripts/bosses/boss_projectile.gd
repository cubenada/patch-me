extends Area2D

const SPEED := 160.0
const MAX_RANGE := 300.0

var direction: Vector2 = Vector2.RIGHT
var _distance: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	var move := direction * SPEED * delta
	position += move
	_distance += move.length()
	if _distance >= MAX_RANGE:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.call("take_damage", 1)
		queue_free()
	elif not (body is CharacterBody2D):
		queue_free()
