extends Node

var patch_version: String = "v0.1.0"
var hitbox_accurate: bool = false
var has_impact_particles: bool = false
var has_hitstop: bool = false
var has_clean_audio: bool = false

var current_weapon: int = 0
var weapons_unlocked: Array[bool] = [false, false, false]

var is_loading_save: bool = false
var saved_scene: String = ""
var saved_player_pos: Vector2 = Vector2.ZERO
var saved_player_health: int = 4

var intro_shown: bool = false
var boss_intro_shown: bool = false

func apply_patch_v020() -> void:
	hitbox_accurate = true
	has_impact_particles = true
	has_hitstop = true
	has_clean_audio = true
	patch_version = "v0.2.0"

func reset() -> void:
	patch_version = "v0.1.0"
	hitbox_accurate = false
	has_impact_particles = false
	has_hitstop = false
	has_clean_audio = false
	current_weapon = 0
	weapons_unlocked = [false, false, false]
	is_loading_save = false
	saved_scene = ""
	saved_player_pos = Vector2.ZERO
	saved_player_health = 4
	intro_shown = false
	boss_intro_shown = false

func save_game(scene: String, player_pos: Vector2, player_health: int) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game", "scene", scene)
	cfg.set_value("player", "x", player_pos.x)
	cfg.set_value("player", "y", player_pos.y)
	cfg.set_value("player", "health", player_health)
	cfg.set_value("state", "patch_version", patch_version)
	cfg.set_value("state", "hitbox_accurate", hitbox_accurate)
	cfg.set_value("state", "has_impact_particles", has_impact_particles)
	cfg.set_value("state", "has_hitstop", has_hitstop)
	cfg.set_value("state", "has_clean_audio", has_clean_audio)
	cfg.set_value("state", "current_weapon", current_weapon)
	cfg.set_value("state", "wu0", weapons_unlocked[0])
	cfg.set_value("state", "wu1", weapons_unlocked[1])
	cfg.set_value("state", "wu2", weapons_unlocked[2])
	cfg.set_value("state", "intro_shown", intro_shown)
	cfg.set_value("state", "boss_intro_shown", boss_intro_shown)
	cfg.save("user://save.cfg")

func load_game() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load("user://save.cfg") != OK:
		return false
	saved_scene = cfg.get_value("game", "scene", "")
	if saved_scene == "":
		return false
	saved_player_pos = Vector2(
		cfg.get_value("player", "x", 0.0),
		cfg.get_value("player", "y", 0.0)
	)
	saved_player_health = cfg.get_value("player", "health", 4)
	patch_version = cfg.get_value("state", "patch_version", "v0.1.0")
	hitbox_accurate = cfg.get_value("state", "hitbox_accurate", false)
	has_impact_particles = cfg.get_value("state", "has_impact_particles", false)
	has_hitstop = cfg.get_value("state", "has_hitstop", false)
	has_clean_audio = cfg.get_value("state", "has_clean_audio", false)
	current_weapon = cfg.get_value("state", "current_weapon", 0)
	weapons_unlocked[0] = cfg.get_value("state", "wu0", false)
	weapons_unlocked[1] = cfg.get_value("state", "wu1", false)
	weapons_unlocked[2] = cfg.get_value("state", "wu2", false)
	intro_shown = cfg.get_value("state", "intro_shown", false)
	boss_intro_shown = cfg.get_value("state", "boss_intro_shown", false)
	is_loading_save = true
	return true

func has_save() -> bool:
	return FileAccess.file_exists("user://save.cfg")

var _hitstop_active: bool = false

func do_hitstop() -> void:
	if _hitstop_active:
		return
	_hitstop_active = true
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.033, true, false, true).timeout
	Engine.time_scale = 1.0
	_hitstop_active = false
