extends CanvasLayer

signal finished

const CHAR_DELAY := 0.025

@onready var text_label: Label = $TextLabel
@onready var prompt_label: Label = $PromptLabel

var _lines: Array = []
var _index: int = 0
var _typing: bool = false
var _waiting: bool = false
var _current_text: String = ""

func setup(lines: Array) -> void:
	_lines = lines
	get_tree().paused = true
	_show_line(0)

func _show_line(idx: int) -> void:
	_index = idx
	_current_text = _lines[idx]
	text_label.text = ""
	prompt_label.visible = false
	_typing = true
	_waiting = false
	_type()

func _type() -> void:
	for ch in _current_text:
		if not _typing:
			break
		text_label.text += ch
		await get_tree().create_timer(CHAR_DELAY, true, false, true).timeout
	text_label.text = _current_text
	_typing = false
	_waiting = true
	prompt_label.text = "[E] Close" if _index >= _lines.size() - 1 else "[E] Next"
	prompt_label.visible = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		return
	if not event.is_action_pressed("interact"):
		return
	if _typing:
		_typing = false
	elif _waiting:
		_waiting = false
		_index += 1
		if _index >= _lines.size():
			get_tree().paused = false
			finished.emit()
			queue_free()
		else:
			_show_line(_index)
