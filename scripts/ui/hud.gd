extends CanvasLayer

@onready var health_label: Label = $HealthLabel
@onready var version_label: Label = $VersionLabel

func _process(_delta: float) -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player:
		health_label.text = "HP: " + str(player.get("health"))
	version_label.text = GameState.patch_version
