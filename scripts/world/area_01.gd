extends Node2D

const DIALOGUE := preload("res://scenes/ui/dialogue.tscn")

func _ready() -> void:
	$Boss.boss_defeated.connect(_on_boss_defeated)
	if not GameState.intro_shown:
		_show_intro()
	_setup_boss_trigger()

func _show_intro() -> void:
	GameState.intro_shown = true
	var dlg := DIALOGUE.instantiate()
	add_child(dlg)
	dlg.setup([
		"[LOG] New project initialized.",
		"[LOG] You thought making a game was going to be easy, didn't you.",
		"[WARNING] Collision detection: broken. Scope: undefined. Deadline: yesterday.",
		"[ERROR] Developer experience: null",
		"[LOG] Welcome to game development.",
	])

func _setup_boss_trigger() -> void:
	if GameState.boss_intro_shown:
		return
	var trigger := Area2D.new()
	trigger.collision_layer = 0
	trigger.collision_mask = 2
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(200, 400)
	shape.shape = rect
	trigger.add_child(shape)
	trigger.position = Vector2(800, 180)
	add_child(trigger)
	trigger.body_entered.connect(func(body: Node2D) -> void:
		if body.is_in_group("player"):
			trigger.queue_free()
			_show_boss_intro()
	)

func _show_boss_intro() -> void:
	GameState.boss_intro_shown = true
	var dlg := DIALOGUE.instantiate()
	add_child(dlg)
	dlg.setup([
		"[ENCOUNTER] Hostile entity detected.",
		"[LOG] Name: \"The Placeholder\"",
		"[LOG] Temporary asset. Added in v0.0.1. Never replaced.",
		"[LOG] This is what happens when you leave TODOs in the code.",
		"[WARNING] The sprite lies. The hitbox is 36px to the right.",
		"[LOG] Attack where it IS. Not where it LOOKS like it is.",
		"[LOG] You'll figure it out. Eventually.",
	])

func _on_boss_defeated() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/patch_notes.tscn")
