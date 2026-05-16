extends Node2D

const FLOAT_DISTANCE := 20.0
const DURATION := 1.0

func setup(amount: int) -> void:
	$Label.text = str(amount)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y - FLOAT_DISTANCE, DURATION)
	tween.tween_property(self, "scale", Vector2(1.6, 1.6), DURATION * 0.35).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, DURATION * 0.65).set_delay(DURATION * 0.35)
	tween.finished.connect(queue_free)
