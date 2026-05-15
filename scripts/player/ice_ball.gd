extends Area2D

const SPEED := 500.0
const MAX_RANGE := 140.0
const BROKEN_PERP_AMOUNT := 62.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var direction: Vector2 = Vector2.RIGHT
var _distance: float = 0.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	if not GameState.hitbox_accurate:
		var perp := Vector2(-direction.y, direction.x)
		collision_shape.position = perp * BROKEN_PERP_AMOUNT

func _process(delta: float) -> void:
	var move := direction * SPEED * delta
	position += move
	_distance += move.length()
	if _distance >= MAX_RANGE:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name != "HurtBox":
		return
	var target := area.get_parent()
	if target.has_method("take_damage"):
		target.take_damage(1)
		if target.has_method("knockback"):
			target.knockback(direction)
		AudioManager.play("hit")
		if GameState.has_hitstop:
			await GameState.do_hitstop()
	queue_free()

func _on_body_entered(_body: Node2D) -> void:
	queue_free()
