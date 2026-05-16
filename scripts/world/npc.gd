extends Node2D

const DIALOGUE := preload("res://scenes/ui/dialogue.tscn")

var _lines: Array = []
var _heals: bool = false
var _player_nearby: bool = false
var _interacting: bool = false
var _used: bool = false

@onready var _prompt: Label = $Prompt

func _ready() -> void:
	$InteractZone.body_entered.connect(_on_body_entered)
	$InteractZone.body_exited.connect(_on_body_exited)
	_prompt.visible = false

func configure(dialogue_lines: Array, should_heal: bool) -> void:
	_lines = dialogue_lines
	_heals = should_heal

func _unhandled_input(event: InputEvent) -> void:
	if _player_nearby and not _interacting and not _used and event.is_action_pressed("interact"):
		_start_dialogue()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = true
		_prompt.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
		_prompt.visible = false

func _start_dialogue() -> void:
	if _lines.is_empty():
		return
	_interacting = true
	_prompt.visible = false
	var dlg := DIALOGUE.instantiate()
	get_tree().current_scene.add_child(dlg)
	dlg.finished.connect(_on_dialogue_finished)
	dlg.setup(_lines)

func _on_dialogue_finished() -> void:
	_interacting = false
	_used = true
	_prompt.visible = false
	if not _heals:
		return
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.call("heal_full")
