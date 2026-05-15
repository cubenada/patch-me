extends Control

@onready var menu_image: TextureRect = $MenuImage

const IMG_W := 1024.0
const IMG_H := 1536.0
const VP_W := 640.0
const VP_H := 360.0

func _ready() -> void:
	var s := minf(VP_W / IMG_W, VP_H / IMG_H)
	menu_image.size = Vector2(IMG_W * s, IMG_H * s)
	menu_image.position = Vector2((VP_W - IMG_W * s) * 0.5, 0.0)
	_setup_button_styles()
	AudioManager.play_music("res://assets/audio/music/Mr.Cat - Bit Piano Music.mp3")

func _setup_button_styles() -> void:
	var empty := StyleBoxEmpty.new()

	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = Color(1.0, 1.0, 1.0, 0.12)

	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = Color(1.0, 1.0, 1.0, 0.28)

	for btn: Button in [$NewGameBtn, $LoadGameBtn, $OptionsBtn, $ExitBtn]:
		btn.flat = false
		btn.add_theme_stylebox_override("normal", empty)
		btn.add_theme_stylebox_override("focus", empty)
		btn.add_theme_stylebox_override("disabled", empty)
		btn.add_theme_stylebox_override("hover", hover_style)
		btn.add_theme_stylebox_override("pressed", pressed_style)
		btn.add_theme_stylebox_override("hover_pressed", pressed_style)
		btn.mouse_entered.connect(_on_btn_hover)

func _on_btn_hover() -> void:
	AudioManager.play("menu_hover")

func _on_new_game_pressed() -> void:
	AudioManager.play("menu_click")
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/world/area_01.tscn")

func _on_load_game_pressed() -> void:
	AudioManager.play("menu_click")
	if GameState.load_game():
		get_tree().change_scene_to_file(GameState.saved_scene)

func _on_options_pressed() -> void:
	AudioManager.play("menu_click")
	get_tree().change_scene_to_file("res://scenes/world/options_menu.tscn")

func _on_exit_pressed() -> void:
	AudioManager.play("menu_click")
	get_tree().quit()
