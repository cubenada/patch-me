extends Control

const SLOT_SIZE := 28.0
const GAP := 4.0
const WEAPONS := ["PROJ", "SHOT", "ICE"]

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var font := ThemeDB.fallback_font
	var total_w := 3.0 * SLOT_SIZE + 2.0 * GAP
	var start_x := (size.x - total_w) / 2.0
	var y := size.y - SLOT_SIZE - 14.0

	for i in 3:
		var x := start_x + i * (SLOT_SIZE + GAP)
		var rect := Rect2(x, y, SLOT_SIZE, SLOT_SIZE)
		var selected := GameState.current_weapon == i
		var unlocked: bool = GameState.weapons_unlocked[i]

		var bg: Color
		var border: Color
		var label: String
		var text_color: Color
		if not unlocked:
			bg = Color(0.05, 0.05, 0.05, 0.75)
			border = Color(0.2, 0.2, 0.2, 0.8)
			label = "?"
			text_color = Color(0.28, 0.28, 0.28)
		elif selected:
			bg = Color(0.25, 0.25, 0.25, 0.9)
			border = Color(0.95, 0.9, 0.2, 1.0)
			label = WEAPONS[i]
			text_color = Color.WHITE
		else:
			bg = Color(0.08, 0.08, 0.08, 0.85)
			border = Color(0.35, 0.35, 0.35, 1.0)
			label = WEAPONS[i]
			text_color = Color(0.45, 0.45, 0.45)

		draw_rect(rect, bg)
		draw_rect(rect, border, false, 1.0)

		var tw := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x
		draw_string(font, Vector2(x + (SLOT_SIZE - tw) / 2.0, y + 18.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, text_color)

		var key_color := Color(0.55, 0.55, 0.55) if unlocked else Color(0.22, 0.22, 0.22)
		var key_str := str(i + 1)
		var kw := font.get_string_size(key_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 7).x
		draw_string(font, Vector2(x + (SLOT_SIZE - kw) / 2.0, y + SLOT_SIZE + 10.0), key_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, key_color)
