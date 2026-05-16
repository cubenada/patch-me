extends Node2D

const DIALOGUE := preload("res://scenes/ui/dialogue.tscn")
const BOSS_MUSIC := "res://assets/audio/music/clemente-panchout-mwfup-chaotic-boss.wav"
const PIPE_TRAP := preload("res://scenes/world/pipe_trap.tscn")
# Each entry: tilemap cell of the pipe tile + direction the projectile shoots
const PIPE_TRAPS_DATA: Array = [
	{"cell": Vector2i(50, 51), "direction": Vector2.DOWN},
	{"cell": Vector2i(55, 51), "direction": Vector2.DOWN},
	{"cell": Vector2i(16, 16), "direction": Vector2.DOWN},
]

const GATE_CELL := Vector2i(33, 36)
const GATE_TRIGGER_RADIUS := 80.0
const GATE_ENEMY_RADIUS := 260.0

@onready var _walls: TileMapLayer = $Walls
@onready var _objects: TileMapLayer = $Objects
@onready var _healer_npc: Node2D = $NPCs/HealerNPC
@onready var _secret_npc: Node2D = $NPCs/SecretNPC

const TRAP_DAMAGE_COOLDOWN := 1.0

var _gate_source_id: int = -1
var _gate_atlas_coords: Vector2i = Vector2i.ZERO
var _gate_alternative: int = 0
var _gate_open: bool = false
var _player_near_gate: bool = false
var _gate_world_pos: Vector2 = Vector2.ZERO
var _trap_timer: float = 0.0
var _trap_layer_index: int = -1

func _ready() -> void:
	$Boss.boss_defeated.connect(_on_boss_defeated)
	$Boss.phase_transition_started.connect(_on_boss_phase_transition)
	if not GameState.boss_intro_shown:
		$Boss.active = false
	if not GameState.intro_shown:
		_show_intro()
	_setup_boss_trigger()
	_setup_gate()
	_find_trap_layer()
	_spawn_pipe_traps()
	_setup_npcs()

func _spawn_pipe_traps() -> void:
	for data: Dictionary in PIPE_TRAPS_DATA:
		var trap := PIPE_TRAP.instantiate()
		add_child(trap)
		trap.global_position = _walls.to_global(_walls.map_to_local(data["cell"] as Vector2i))
		trap.configure(data["direction"] as Vector2)

func _setup_npcs() -> void:
	_healer_npc.configure([
		"Hey. You found me.",
		"I've been stuck in this area since v0.0.1.",
		"The developer forgot to write an exit condition for me. Classic.",
		"I tried submitting a bug report. It got closed as 'won't fix'.",
		"Anyway. You look like you've taken a hit or two.",
		"Here. Off the books. Don't tell the system.",
		"[HP RESTORED]",
	], true)

	_secret_npc.configure([
		"Oh. You found me.",
		"I didn't think anyone would check back here.",
		"I'm what's left of the design document.",
		"The developer wrote 47 pages of lore for this world.",
		"None of it made it into the game.",
		"This conversation is the only content that survived.",
		"// TODO: add meaningful NPC dialogue",
		"That comment is four years old.",
		"Anyway. Thanks for reading.",
		"Most players don't make it this far.",
	], false)

func _process(delta: float) -> void:
	if _player_near_gate and _gate_source_id != -1:
		if _has_enemies_nearby():
			_close_gate()
		else:
			_open_gate()
	_check_traps(delta)

func _find_trap_layer() -> void:
	var ts := _objects.tile_set
	if not ts:
		return
	for i in ts.get_custom_data_layers_count():
		if ts.get_custom_data_layer_name(i) == "is_trap":
			_trap_layer_index = i
			return

func _check_traps(delta: float) -> void:
	if _trap_layer_index == -1:
		return
	if _trap_timer > 0.0:
		_trap_timer -= delta
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	var cell := _objects.local_to_map(_objects.to_local(player.global_position))
	var tile_data := _objects.get_cell_tile_data(cell)
	if tile_data and tile_data.get_custom_data("is_trap"):
		player.call("take_damage", 1)
		_trap_timer = TRAP_DAMAGE_COOLDOWN

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
	rect.size = Vector2(352, 224)
	shape.shape = rect
	trigger.add_child(shape)
	trigger.position = Vector2(944, 160)
	add_child(trigger)
	trigger.body_entered.connect(func(body: Node2D) -> void:
		if body.is_in_group("player"):
			trigger.queue_free()
			_show_boss_intro()
	)

func _show_boss_intro() -> void:
	GameState.boss_intro_shown = true
	AudioManager.play_music_fade_in(BOSS_MUSIC, 2.0)
	var dlg := DIALOGUE.instantiate()
	add_child(dlg)
	dlg.finished.connect(func() -> void: $Boss.active = true)
	dlg.setup([
		"[ENCOUNTER] Hostile entity detected.",
		"[LOG] Name: \"The Placeholder\"",
		"[LOG] Temporary asset. Added in v0.0.1. Never replaced.",
		"[LOG] This is what happens when you leave TODOs in the code.",
		"[WARNING] The sprite lies. The hitbox is 36px to the right.",
		"[LOG] Attack where it IS. Not where it LOOKS like it is.",
		"[LOG] You'll figure it out. Eventually.",
	])

func _setup_gate() -> void:
	_gate_source_id = _walls.get_cell_source_id(GATE_CELL)
	if _gate_source_id == -1:
		return
	_gate_atlas_coords = _walls.get_cell_atlas_coords(GATE_CELL)
	_gate_alternative = _walls.get_cell_alternative_tile(GATE_CELL)
	_gate_world_pos = _walls.to_global(_walls.map_to_local(GATE_CELL))

	var trigger := Area2D.new()
	trigger.collision_layer = 0
	trigger.collision_mask = 2
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = GATE_TRIGGER_RADIUS
	shape.shape = circle
	trigger.add_child(shape)
	add_child(trigger)
	trigger.global_position = _gate_world_pos
	trigger.body_entered.connect(func(body: Node2D) -> void:
		if body.is_in_group("player"):
			_player_near_gate = true
	)
	trigger.body_exited.connect(func(body: Node2D) -> void:
		if body.is_in_group("player"):
			_player_near_gate = false
			_close_gate()
	)

func _has_enemies_nearby() -> bool:
	for enemy: Node in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			var dist := (enemy as Node2D).global_position.distance_to(_gate_world_pos)
			if dist <= GATE_ENEMY_RADIUS:
				return true
	return false

func _open_gate() -> void:
	if _gate_open:
		return
	_gate_open = true
	_walls.erase_cell(GATE_CELL)

func _close_gate() -> void:
	if not _gate_open:
		return
	_gate_open = false
	_walls.set_cell(GATE_CELL, _gate_source_id, _gate_atlas_coords, _gate_alternative)

func _on_boss_phase_transition() -> void:
	var dlg := DIALOGUE.instantiate()
	add_child(dlg)
	dlg.finished.connect(func() -> void: $Boss.resume_phase_two())
	dlg.setup([
		"[LOG] HP below 50%. Running emergency_patch.exe...",
		"[LOG] Scanning Git history for a fix...",
		"[LOG] Found it. Some idiot pushed a Phase 2.",
		"[LOG] That idiot was me.",
		"[ERROR] Spread shot enabled. Triple projectile. 0.67s cooldown.",
		"[WARNING] I added this at 2am. I don't remember why.",
		"[LOG] Good luck. You'll need it.",
	])

func _on_boss_defeated() -> void:
	AudioManager.fade_out_music(0.8)
	await get_tree().create_timer(0.8).timeout
	get_tree().change_scene_to_file("res://scenes/ui/patch_notes.tscn")
