extends UICanvas

var score: int = 0
var high: int = 0
var status: String = "同僚のよそ見を待とう"
var chance: bool = false
var save_failed: bool = false
var missed_chances: int = 0
var miss_limit: int = 5

func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 72), INK)
	draw_rect(Rect2(0, 70, 960, 2), Color("6a8c85"))
	text_at("横取りデイズ", Vector2(26, 44), 25, GOLD)
	text_at("SCORE", Vector2(290, 25), 13, MUTED)
	text_at("%06d" % score, Vector2(290, 56), 28)
	text_at("HIGH SCORE", Vector2(470, 25), 13, MUTED)
	text_at("%06d" % high, Vector2(470, 56), 28, GOLD)
	text_at("勤務状況", Vector2(695, 24), 13, MUTED)
	var hyper := score > DifficultyManager.HYPER_THRESHOLD
	text_at(DifficultyManager.level_name(score), Vector2(695, 51), 20, GOLD if hyper else MINT)
	panel(Rect2(14, 111, 80, 240), INK, GOLD)
	center_text("横取り", 135, 16, GOLD, 54)
	center_text("したい", 157, 16, GOLD, 54)
	for i in range(miss_limit):
		draw_rect(Rect2(34, 292 - i * 25, 40, 20), Color("db735d") if i < missed_chances else Color("304b57"))
	center_text("%d / %d" % [missed_chances, miss_limit], 336, 16, PAPER, 54)
	# Name plates anchor the three roles in the office scene.
	for i in range(3):
		var x: float = [244.0, 476.0, 708.0][i]
		panel(Rect2(x - 78, 433, 156, 26), Color("29434a"), Color("59776f"))
		center_text(["澤野さん", "横取り対象", "会話相手"][i], 452, 15, GOLD if i == 0 else PAPER, x)
	draw_rect(Rect2(0, 478, 960, 62), INK)
	draw_rect(Rect2(0, 478, 960, 2), Color("6a8c85"))
	panel(Rect2(26, 493, 93, 30), GOLD if chance else Color("304b57"), GOLD if chance else MUTED)
	center_text("ENTER", 515, 16, INK if chance else PAPER, 72)
	text_at(status, Vector2(143, 516), 21, GOLD if chance else PAPER)
	text_at("今だ！の時だけ押す", Vector2(724, 515), 17, MUTED)
	if save_failed:
		text_at("保存できません：今回の記録はこの起動中のみ保持", Vector2(280, 92), 15, GOLD)
