extends Control

const IMG_W := 1024.0
const IMG_H := 1536.0
const VP_W := 640.0
const VP_H := 360.0

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(640, 360),
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
]

@onready var menu_image: TextureRect = $MenuImage
@onready var fullscreen_label: Label = $FullscreenLabel
@onready var res_label: Label = $ResLabel
@onready var master_label: Label = $MasterLabel
@onready var music_label: Label = $MusicLabel
@onready var sfx_label: Label = $SFXLabel

var is_fullscreen: bool = false
var res_index: int = 2
var vol_master: int = 10
var vol_music: int = 80
var vol_sfx: int = 80

func _ready() -> void:
	var s := minf(VP_W / IMG_W, VP_H / IMG_H)
	menu_image.size = Vector2(IMG_W * s, IMG_H * s)
	menu_image.position = Vector2((VP_W - IMG_W * s) * 0.5, 0.0)
	_setup_button_styles()
	_connect_signals()
	_load_settings()
	_update_labels()

func _setup_button_styles() -> void:
	var empty := StyleBoxEmpty.new()
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(1.0, 1.0, 1.0, 0.12)
	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = Color(1.0, 1.0, 1.0, 0.25)

	for btn: Button in [
		$FullscreenBtn, $ResLeftBtn, $ResRightBtn,
		$MasterLeftBtn, $MasterRightBtn,
		$MusicLeftBtn, $MusicRightBtn,
		$SFXLeftBtn, $SFXRightBtn,
		$BackBtn,
	]:
		btn.flat = false
		btn.add_theme_stylebox_override("normal", empty)
		btn.add_theme_stylebox_override("focus", empty)
		btn.add_theme_stylebox_override("disabled", empty)
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", pressed_style)
		btn.add_theme_stylebox_override("hover_pressed", pressed_style)
		btn.mouse_entered.connect(func(): AudioManager.play("menu_hover"))

func _connect_signals() -> void:
	$FullscreenBtn.pressed.connect(_on_fullscreen_pressed)
	$ResLeftBtn.pressed.connect(_on_res_left_pressed)
	$ResRightBtn.pressed.connect(_on_res_right_pressed)
	$MasterLeftBtn.pressed.connect(_on_master_left_pressed)
	$MasterRightBtn.pressed.connect(_on_master_right_pressed)
	$MusicLeftBtn.pressed.connect(_on_music_left_pressed)
	$MusicRightBtn.pressed.connect(_on_music_right_pressed)
	$SFXLeftBtn.pressed.connect(_on_sfx_left_pressed)
	$SFXRightBtn.pressed.connect(_on_sfx_right_pressed)
	$BackBtn.pressed.connect(_on_back_pressed)

func _update_labels() -> void:
	fullscreen_label.text = "ON" if is_fullscreen else "OFF"
	var r := RESOLUTIONS[res_index]
	res_label.text = "%dx%d" % [r.x, r.y]
	master_label.text = "%d%%" % vol_master
	music_label.text = "%d%%" % vol_music
	sfx_label.text = "%d%%" % vol_sfx

func _apply_settings() -> void:
	var root := get_tree().root
	if is_fullscreen:
		root.mode = Window.MODE_FULLSCREEN
	else:
		root.mode = Window.MODE_WINDOWED
		root.size = RESOLUTIONS[res_index]

	var master_idx := AudioServer.get_bus_index("Master")
	var music_idx := AudioServer.get_bus_index("Music")
	var sfx_idx := AudioServer.get_bus_index("SFX")
	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, linear_to_db(vol_master / 100.0) if vol_master > 0 else -80.0)
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(vol_music / 100.0) if vol_music > 0 else -80.0)
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(vol_sfx / 100.0) if vol_sfx > 0 else -80.0)

func _on_fullscreen_pressed() -> void:
	AudioManager.play("menu_click")
	is_fullscreen = not is_fullscreen
	_update_labels()
	_apply_settings()

func _on_res_left_pressed() -> void:
	AudioManager.play("menu_click")
	res_index = max(0, res_index - 1)
	_update_labels()
	if not is_fullscreen:
		_apply_settings()

func _on_res_right_pressed() -> void:
	AudioManager.play("menu_click")
	res_index = min(RESOLUTIONS.size() - 1, res_index + 1)
	_update_labels()
	if not is_fullscreen:
		_apply_settings()

func _on_master_left_pressed() -> void:
	AudioManager.play("menu_click")
	vol_master = max(0, vol_master - 10)
	_update_labels()
	_apply_settings()

func _on_master_right_pressed() -> void:
	AudioManager.play("menu_click")
	vol_master = min(100, vol_master + 10)
	_update_labels()
	_apply_settings()

func _on_music_left_pressed() -> void:
	AudioManager.play("menu_click")
	vol_music = max(0, vol_music - 10)
	_update_labels()
	_apply_settings()

func _on_music_right_pressed() -> void:
	AudioManager.play("menu_click")
	vol_music = min(100, vol_music + 10)
	_update_labels()
	_apply_settings()

func _on_sfx_left_pressed() -> void:
	AudioManager.play("menu_click")
	vol_sfx = max(0, vol_sfx - 10)
	_update_labels()
	_apply_settings()

func _on_sfx_right_pressed() -> void:
	AudioManager.play("menu_click")
	vol_sfx = min(100, vol_sfx + 10)
	_update_labels()
	_apply_settings()

func _on_back_pressed() -> void:
	AudioManager.play("menu_click")
	_save_settings()
	get_tree().change_scene_to_file("res://scenes/world/main_menu.tscn")

func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("video", "fullscreen", is_fullscreen)
	cfg.set_value("video", "res_index", res_index)
	cfg.set_value("audio", "master", vol_master)
	cfg.set_value("audio", "music", vol_music)
	cfg.set_value("audio", "sfx", vol_sfx)
	cfg.save("user://settings.cfg")

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") != OK:
		return
	is_fullscreen = cfg.get_value("video", "fullscreen", false)
	res_index = cfg.get_value("video", "res_index", 2)
	vol_master = cfg.get_value("audio", "master", 10)
	vol_music = cfg.get_value("audio", "music", 80)
	vol_sfx = cfg.get_value("audio", "sfx", 80)
	_apply_settings()
