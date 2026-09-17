extends UICanvas

const SAD = preload("res://assets/characters/sawano_sad.png")
var score: int = 0
var high: int = 0
var new_record: bool = false
var quit_from_frustration: bool = false

func _draw() -> void:
	draw_rect(Rect2(0, 72, 960, 468), Color(0.04, 0.08, 0.13, 0.79))
	panel(Rect2(154, 92, 652, 374), INK, Color("879d97"))
	center_text("GAME OVER", 143, 40, GOLD)
	draw_texture_rect(SAD, Rect2(192, 183, 144, 192), false)
	center_text("自主退職" if quit_from_frustration else "カムチャッカ行き", 406, 16, MUTED, 269)
	if quit_from_frustration:
		text_at("横取りしたいゲージが満タン！", Vector2(354, 194), 21, GOLD)
		text_at(GameManager.QUIT_LINE, Vector2(354, 235), 21)
		text_at("澤野さんは仕事を辞めてしまった", Vector2(354, 273), 20, MUTED)
	else:
		text_at("横取りが見つかってしまい、", Vector2(365, 200), 23)
		text_at("カムチャッカ半島オフィスに", Vector2(365, 234), 23)
		text_at("左遷されてしまった", Vector2(365, 268), 23)
	text_at("今回のスコア：%06d" % score, Vector2(365, 323), 24)
	text_at("ハイスコア：%06d" % high, Vector2(365, 359), 24, GOLD)
	if new_record: text_at("NEW RECORD!", Vector2(365, 391), 20, MINT)
	panel(Rect2(373, 410, 290, 38), GOLD, GOLD)
	center_text("Enterで再挑戦", 437, 22, INK, 518)
