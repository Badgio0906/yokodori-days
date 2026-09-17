class_name UICanvas
extends Control

const FONT = preload("res://assets/fonts/DotGothic16-Regular.ttf")
const INK := Color("172b3b")
const PAPER := Color("f3ead1")
const MUTED := Color("a9bdb8")
const GOLD := Color("f4cd55")
const MINT := Color("9dd8c0")

func text_at(value: String, at: Vector2, size: int = 20, color: Color = PAPER) -> void:
	draw_string(FONT, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func center_text(value: String, y: float, size: int = 20, color: Color = PAPER, x: float = 480.0) -> void:
	var width := FONT.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	text_at(value, Vector2(x - width * 0.5, y), size, color)

func panel(rect: Rect2, color: Color = INK, border: Color = MUTED) -> void:
	draw_rect(Rect2(rect.position + Vector2(6, 6), rect.size), Color(0.03, 0.08, 0.12, 0.65))
	draw_rect(rect, color)
	draw_rect(rect, border, false, 2.0)
