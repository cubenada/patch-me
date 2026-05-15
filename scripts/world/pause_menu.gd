extends CanvasLayer

func _ready() -> void:
	get_tree().paused = true
	_setup_buttons()
	$Panel/ResumeBtn.pressed.connect(_on_resume)
	$Panel/MainMenuBtn.pressed.connect(_on_main_menu)

func _setup_buttons() -> void:
	var empty := StyleBoxEmpty.new()
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(1, 1, 1, 0.12)
	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = Color(1, 1, 1, 0.28)
	for btn: Button in [$Panel/ResumeBtn, $Panel/MainMenuBtn]:
		btn.flat = false
		btn.add_theme_stylebox_override("normal", empty)
		btn.add_theme_stylebox_override("focus", empty)
		btn.add_theme_stylebox_override("disabled", empty)
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", pressed_style)
		btn.add_theme_stylebox_override("hover_pressed", pressed_style)
		btn.mouse_entered.connect(func(): AudioManager.play("menu_hover"))

func _on_resume() -> void:
	AudioManager.play("menu_click")
	get_tree().paused = false
	queue_free()

func _on_main_menu() -> void:
	AudioManager.play("menu_click")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/world/main_menu.tscn")
