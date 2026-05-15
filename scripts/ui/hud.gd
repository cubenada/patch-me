extends CanvasLayer

@onready var health_label: Label = $HealthLabel
@onready var version_label: Label = $VersionLabel

var _player: Node = null

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	if _player:
		health_label.text = "HP: " + str(_player.get("health"))
	version_label.text = GameState.patch_version
