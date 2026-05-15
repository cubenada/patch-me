extends Area2D

@export var weapon_id: int = 0

const FRAME_RECTS: Array[Rect2] = [
	Rect2(80, 112, 16, 16),   # fechado
	Rect2(96, 112, 16, 16),   # levemente aberto
	Rect2(112, 112, 16, 16),  # meio aberto
	Rect2(128, 112, 16, 16),  # totalmente aberto
]

@onready var sprite: Sprite2D = $Sprite2D

var player_nearby: bool = false
var opened: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if GameState.weapons_unlocked[weapon_id]:
		opened = true
		sprite.region_rect = FRAME_RECTS[3]

func _process(_delta: float) -> void:
	if player_nearby and not opened and Input.is_action_just_pressed("interact"):
		_open()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		queue_redraw()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		queue_redraw()

func _open() -> void:
	opened = true
	queue_redraw()
	AudioManager.play("chest_open")
	for frame_rect: Rect2 in FRAME_RECTS:
		sprite.region_rect = frame_rect
		await get_tree().create_timer(0.1).timeout
	GameState.weapons_unlocked[weapon_id] = true
	GameState.current_weapon = weapon_id

func _draw() -> void:
	if player_nearby and not opened:
		var font := ThemeDB.fallback_font
		draw_string(font, Vector2(-8, -14), "[E]", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color.WHITE)
