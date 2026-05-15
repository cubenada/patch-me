extends Camera2D

var _shake_amount: float = 0.0
var _shake_timer: float = 0.0
var _shake_duration: float = 0.15

func _ready() -> void:
	add_to_group("camera")

func shake(amount: float = 4.0, duration: float = 0.15) -> void:
	_shake_amount = amount
	_shake_timer = duration
	_shake_duration = duration

func _process(delta: float) -> void:
	if _shake_timer > 0.0:
		_shake_timer -= delta
		var t := _shake_timer / _shake_duration
		var current := _shake_amount * t
		offset = Vector2(randf_range(-current, current), randf_range(-current, current))
	else:
		offset = Vector2.ZERO
