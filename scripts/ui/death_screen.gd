extends CanvasLayer

const RELOAD_DELAY := 2.0

const _MESSAGES: Array[String] = [
	"SIGSEGV (Segmentation fault)",
	"Process killed",
	"FATAL: player.hp < 0\n(this was not supposed to happen)",
	"assert(player.hp > 0)  FAILED",
	"Uncaught Exception: DeadPlayerError",
	"todo: add respawn logic\n// this is the respawn logic",
]

@onready var _msg: Label = $Panel/Message

func _ready() -> void:
	AudioManager.stop_music()
	get_tree().paused = true
	_msg.text = _MESSAGES[randi() % _MESSAGES.size()]
	_reload()

func _reload() -> void:
	await get_tree().create_timer(RELOAD_DELAY, true).timeout
	get_tree().paused = false
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/world/area_01.tscn")
