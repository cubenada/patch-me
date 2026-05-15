extends CanvasLayer

const NOTES_V020 := """[table=2]
[cell]━━━━━━━━━━━━━━━━━━━━━━━━━
 PATCH ME — v0.2.0
━━━━━━━━━━━━━━━━━━━━━━━━━

 FIXED
 • Hitbox offset corrected
   (was 48px off, sorry)
 • Attacks no longer miss
 • Enemy range fixed

━━━━━━━━━━━━━━━━━━━━━━━━━[/cell]
[cell]━━━━━━━━━━━━━━━━━━━━━━━━━
 ADDED
━━━━━━━━━━━━━━━━━━━━━━━━━

 • Impact feedback on hit
 • Hit stop (2 frames)
 • Enemy flinch

 KNOWN ISSUES
 • Everything else
━━━━━━━━━━━━━━━━━━━━━━━━━[/cell]
[/table]"""

@onready var text_label: RichTextLabel = $Panel/RichTextLabel

func _ready() -> void:
	text_label.text = ""
	_type_notes()

func _type_notes() -> void:
	for ch in NOTES_V020:
		text_label.text += ch
		await get_tree().create_timer(0.018).timeout
	await get_tree().create_timer(3.0).timeout
	_finish()

func _finish() -> void:
	GameState.apply_patch_v020()
	get_tree().change_scene_to_file("res://scenes/world/area_01.tscn")
