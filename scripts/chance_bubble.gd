extends UICanvas

var fraction: float = 1.0

func _draw() -> void:
	panel(Rect2(162, 173, 164, 62), GOLD, PAPER)
	draw_colored_polygon(PackedVector2Array([Vector2(227, 235), Vector2(241, 248), Vector2(250, 235)]), GOLD)
	center_text("今だ！", 213, 30, INK, 244)
	draw_rect(Rect2(172, 223, 144, 4), Color("ac923c"))
	draw_rect(Rect2(172, 223, 144 * fraction, 4), INK)
