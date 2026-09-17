extends UICanvas

var remaining: float = 0.0
var banana: bool = false
var task_points: int = 100
var banana_points: int = 300

func show_score(with_banana: bool, task_value: int = 100, banana_value: int = 300) -> void:
	banana = with_banana
	task_points = task_value
	banana_points = banana_value
	remaining = 1.35
	show()
	queue_redraw()

func _process(delta: float) -> void:
	if remaining > 0.0:
		remaining -= delta
		queue_redraw()
	else: hide()

func _draw() -> void:
	var lift := -minf((1.35 - remaining) * 12.0, 12.0)
	panel(Rect2(68, 112 + lift, 288, 48 if not banana else 94), INK, GOLD if banana else MINT)
	center_text("仕事GET！ +%d" % task_points, 145 + lift, 24, MINT, 212)
	if banana: center_text("バナナGET！！ +%d" % banana_points, 186 + lift, 25, GOLD, 212)
