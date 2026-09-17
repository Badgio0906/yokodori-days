extends UICanvas

const HERO = preload("res://assets/characters/sawano_steal.png")
const BANANA = preload("res://assets/items/banana.png")
var clock: float = 0.0

func _process(delta: float) -> void:
	clock += delta
	if visible: queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color(0.04, 0.09, 0.13, 0.65))
	text_at("SAWANO'S OFFICE / SCORE ATTACK", Vector2(54, 51), 16, MINT)
	text_at("01  /  YOKODORI DAYS", Vector2(674, 51), 16, MUTED)
	panel(Rect2(52, 83, 856, 374), INK, Color("66877f"))
	draw_rect(Rect2(52, 83, 8, 374), GOLD)
	text_at("澤野さんの", Vector2(88, 143), 32, PAPER)
	text_at("横取りデイズ", Vector2(84, 212), 62, GOLD)
	text_at("～お前の仕事は俺の仕事～", Vector2(90, 256), 23, PAPER)
	draw_line(Vector2(90, 279), Vector2(588, 279), Color("4c686b"), 2)
	text_at("同僚がよそ見したら", Vector2(92, 314), 22)
	text_at("Enterで仕事を横取り！", Vector2(92, 346), 22)
	text_at("バナナは高得点！", Vector2(92, 392), 20, GOLD)
	draw_rect(Rect2(650, 117, 220, 237), Color("29454e"))
	for y in range(127, 350, 12):
		draw_line(Vector2(653, y), Vector2(867, y), Color("2c4a51"), 2)
	draw_texture_rect(HERO, Rect2(684, 144, 144, 192), false)
	draw_texture_rect(BANANA, Rect2(790, 247, 72, 60), false)
	center_text("澤野さん / 横取り担当", 382, 16, MUTED, 760)
	if fmod(clock, 1.3) < 0.95:
		panel(Rect2(642, 400, 230, 38), GOLD, GOLD)
		center_text("Enterで開始", 427, 22, INK, 757)
	text_at("ONE BUTTON.  ENDLESS AMBITION.", Vector2(54, 499), 16, MUTED)
	text_at("仕事 +%d   /   バナナ +%d" % [GameManager.TASK_SCORE, GameManager.BANANA_SCORE], Vector2(631, 499), 16, GOLD)
