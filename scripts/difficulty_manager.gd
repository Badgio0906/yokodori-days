class_name DifficultyManager
extends RefCounted

# Larger values make difficulty rise more slowly; all changes are continuous.
const DIFFICULTY_SCORE_SCALE: float = 2400.0
const HYPER_THRESHOLD: int = 10000
const HYPER_TIME_SCALE: float = 0.5

static func settings(score: int) -> Dictionary:
	var pressure := 1.0 - exp(-float(score) / DIFFICULTY_SCORE_SCALE)
	var speed := HYPER_TIME_SCALE if score > HYPER_THRESHOLD else 1.0
	return {
		"min_work_time": lerpf(2.0, 0.7, pressure) * speed,
		"max_work_time": lerpf(4.0, 1.6, pressure) * speed,
		"safe_window": lerpf(1.4, 0.42, pressure) * speed,
		"distraction_duration": lerpf(2.1, 0.95, pressure) * speed,
		"return_duration": 0.25 * speed,
	}

static func level_name(score: int) -> String:
	if score > HYPER_THRESHOLD: return "ハイパー横取りタイム"
	if score < 500: return "のんびり勤務"
	if score < 1500: return "仕事が増えてきた"
	if score < 3000: return "忙しいオフィス"
	return "超・繁忙期"
