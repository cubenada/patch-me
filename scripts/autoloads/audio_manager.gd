extends Node

const SFX_PATH := "res://assets/audio/sfx/"

var _players: Dictionary = {}
var _music: AudioStreamPlayer

func _ready() -> void:
	_setup_buses()
	_apply_saved_volumes()
	_music = AudioStreamPlayer.new()
	_music.bus = "Music"
	add_child(_music)
	_load("attack",     "attack.wav")
	_load("hit",        "hit.wav")
	_load("player_hurt","player_hurt.wav")
	_load("enemy_die",  "enemy_die.wav")
	_load("boss_hit",   "boss_hit.wav")
	_load("boss_die",   "boss_die.wav")
	_load("dash",       "dash.wav")
	_load("chest_open", "01_chest_open_1.wav")
	_load("menu_hover", "Powerup7.wav")
	_load("menu_click", "Blip_Select7.wav")
	_load("attack_w0",  "Laser_Shoot.wav")
	_load("attack_w1",  "Laser_Shoot5.wav")
	_load("attack_w2",  "Laser_Shoot3.wav")

func play(sound_name: String) -> void:
	if not _players.has(sound_name):
		return
	if GameState.has_clean_audio:
		var p: AudioStreamPlayer = _players[sound_name]
		if p.stream:
			p.pitch_scale = 1.0
			p.play()
	else:
		_play_broken(sound_name)

const HEAVY_DELAY_SOUNDS := ["hit", "player_hurt"]

func _play_broken(sound_name: String) -> void:
	if randf() < 0.15:
		return
	var p: AudioStreamPlayer = _players[sound_name]
	if not p.stream:
		return
	p.pitch_scale = randf_range(0.72, 1.38)
	var delay: float
	if sound_name in HEAVY_DELAY_SOUNDS:
		delay = randf_range(0.85, 1.15)
	else:
		delay = randf_range(0.0, 0.13)
	if delay > 0.02:
		await get_tree().create_timer(delay).timeout
	p.play()

func _apply_saved_volumes() -> void:
	var cfg := ConfigFile.new()
	var vol_master := 10
	var vol_music := 80
	var vol_sfx := 80
	if cfg.load("user://settings.cfg") == OK:
		vol_master = cfg.get_value("audio", "master", 10)
		vol_music = cfg.get_value("audio", "music", 80)
		vol_sfx = cfg.get_value("audio", "sfx", 80)
	var master_idx := AudioServer.get_bus_index("Master")
	var music_idx := AudioServer.get_bus_index("Music")
	var sfx_idx := AudioServer.get_bus_index("SFX")
	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, linear_to_db(vol_master / 100.0) if vol_master > 0 else -80.0)
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(vol_music / 100.0) if vol_music > 0 else -80.0)
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(vol_sfx / 100.0) if vol_sfx > 0 else -80.0)

func _setup_buses() -> void:
	for bus_name in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			var idx := AudioServer.bus_count - 1
			AudioServer.set_bus_name(idx, bus_name)
			AudioServer.set_bus_send(idx, "Master")

func play_music(path: String, volume_db: float = 0.0) -> void:
	if not ResourceLoader.exists(path):
		return
	if _music.playing and _music.stream == load(path):
		return
	var stream := load(path)
	if stream is AudioStreamMP3:
		stream.loop = true
	_music.stream = stream
	_music.volume_db = volume_db
	_music.play()

func stop_music() -> void:
	_music.stop()

func _load(key: String, file: String) -> void:
	var p := AudioStreamPlayer.new()
	p.bus = "SFX"
	add_child(p)
	var path := file if file.begins_with("res://") else SFX_PATH + file
	if ResourceLoader.exists(path):
		p.stream = load(path)
	_players[key] = p
