extends Node2D

const DIALOGUE := preload("res://scenes/ui/dialogue.tscn")
const GATE_CELL := Vector2i(33, 36)
const GATE_TRIGGER_RADIUS := 80.0
const GATE_ENEMY_RADIUS := 260.0

@onready var _walls: TileMapLayer = $Walls
@onready var _objects: TileMapLayer = $Objects

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
	if not GameState.boss_intro_shown:
		$Boss.active = false
	if not GameState.intro_shown:
		_show_intro()
	_setup_boss_trigger()
	_setup_gate()
	_find_trap_layer()

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

func _on_boss_defeated() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/patch_notes.tscn")
