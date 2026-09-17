class_name HighScoreManager
extends RefCounted

var save_path: String = "user://high_score.cfg"
var high_score: int = 0
var save_failed: bool = false

func load_score() -> void:
	var config := ConfigFile.new()
	if config.load(save_path) == OK:
		var value: Variant = config.get_value("scores", "best", 0)
		if value is int:
			high_score = maxi(0, value)

func record(score: int) -> bool:
	if score <= high_score: return false
	high_score = score
	var config := ConfigFile.new()
	config.set_value("scores", "best", high_score)
	save_failed = config.save(save_path) != OK
	if save_failed:
		push_warning("High score could not be saved; retained for this session.")
	return true
