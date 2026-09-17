class_name GameManager
extends Node2D

signal game_finished(score: int, high: int, record: bool)
enum GameState { TITLE, PLAYING, GAME_OVER }
const TASK_SCORE: int = 100
const BANANA_SCORE: int = 300
const INPUT_LOCK_SECONDS: float = 0.20
const MISSES_TO_QUIT: int = 5
const QUIT_LINE: String = "横取りできなならこんな仕事辞める！"
const PEEL_TEXTURE = preload("res://assets/items/banana_peel.png")
const STACK_TEXTURE = preload("res://assets/items/paper_stack.png")
const BANANA_TEXTURE = preload("res://assets/items/banana.png")
const TASK_TEXTURE = preload("res://assets/items/task.png")
const FONT = preload("res://assets/fonts/DotGothic16-Regular.ttf")

@onready var target: TargetCoworker = $TargetCoworker
@onready var sawano = $Sawano
@onready var coworker: CharacterVisual = $Coworker
@onready var hud = $HUD
@onready var bubble = $ChanceBubble
@onready var popup = $ScorePopup

var state: GameState = GameState.TITLE
var scores := HighScoreManager.new()
var score: int = 0
var run_best_at_start: int = 0
var stolen_tasks: int = 0
var stolen_bananas: int = 0
var input_lock: float = 0.0
var caught_remaining: float = 0.0
var is_caught: bool = false
var flight_remaining: float = 0.0
var flight_banana: bool = false
var clock: float = 0.0
var missed_chances: int = 0
var quit_from_frustration: bool = false

func _ready() -> void:
	scores.load_score()
	target.task_stolen.connect(_on_task_stolen)
	target.banana_stolen.connect(_on_banana_stolen)
	target.caught_player.connect(_on_caught)
	target.chance_missed.connect(_on_chance_missed)
	target.distraction_started.connect(_on_distraction)
	target.steal_window_started.connect(func(): bubble.show())
	target.steal_window_ended.connect(func(): bubble.hide())
	hud.hide()
	bubble.hide()
	popup.hide()

func start_game() -> void:
	state = GameState.PLAYING
	score = 0
	run_best_at_start = scores.high_score
	stolen_tasks = 0
	stolen_bananas = 0
	input_lock = 0.0
	is_caught = false
	missed_chances = 0
	quit_from_frustration = false
	caught_remaining = 0.0
	flight_remaining = 0.0
	popup.remaining = 0.0
	popup.hide()
	for player in $Audio.get_children(): player.stop()
	sawano.reset()
	coworker.set_pose("working")
	target.apply_difficulty(0)
	target.reset()
	hud.show()
	_update_hud()

func handle_enter() -> void:
	if state == GameState.PLAYING and not is_caught and input_lock <= 0.0:
		target.attempt_steal()

func _on_distraction(kind: int) -> void:
	if kind == TargetCoworker.CoworkerState.PHONE:
		$Audio/phone_ring.play()

func _on_task_stolen() -> void:
	score += TASK_SCORE
	stolen_tasks += 1
	input_lock = INPUT_LOCK_SECONDS
	flight_remaining = 0.42
	flight_banana = false
	sawano.celebrate(false)
	popup.show_score(false, TASK_SCORE, BANANA_SCORE)
	$Audio/steal_success.play()
	_record_and_tune()

func _on_banana_stolen() -> void:
	score += BANANA_SCORE
	stolen_bananas += 1
	flight_banana = true
	sawano.celebrate(true)
	popup.show_score(true, TASK_SCORE, BANANA_SCORE)
	$Audio/banana_get.play()
	_record_and_tune()

func _record_and_tune() -> void:
	# Persist immediately, including if the browser is closed mid-run.
	scores.record(score)
	target.apply_difficulty(score)
	_update_hud()

func _on_caught() -> void:
	target.active = false
	is_caught = true
	caught_remaining = 0.65
	bubble.hide()
	popup.hide()
	popup.remaining = 0.0
	sawano.celebration_remaining = 0.0
	sawano.set_pose("sad")
	$Audio/phone_ring.stop()
	$Audio/caught.play()

func _on_chance_missed() -> void:
	if state != GameState.PLAYING or is_caught: return
	missed_chances = mini(missed_chances + 1, MISSES_TO_QUIT)
	if missed_chances == MISSES_TO_QUIT:
		quit_from_frustration = true
		_on_caught()
	_update_hud()

func paper_count() -> int:
	return score / TASK_SCORE

func _finish_game() -> void:
	state = GameState.GAME_OVER
	$Audio/game_over.play()
	game_finished.emit(score, scores.high_score, score > run_best_at_start)

func _update_hud() -> void:
	hud.score = score
	hud.high = scores.high_score
	hud.chance = target.can_be_stolen and not is_caught
	hud.save_failed = scores.save_failed
	hud.missed_chances = missed_chances
	hud.miss_limit = MISSES_TO_QUIT
	if is_caught:
		hud.status = "横取りしたいゲージが満タン！" if quit_from_frustration else "あっ、見つかった…！"
	elif target.can_be_stolen:
		hud.status = "今だ！ Enterで横取り！"
	elif target.stolen_this_event:
		hud.status = "横取り成功！ 次のチャンスを待とう"
	else:
		hud.status = "同僚のよそ見を待とう"
	hud.queue_redraw()

func _process(delta: float) -> void:
	clock += delta
	input_lock = maxf(0.0, input_lock - delta)
	flight_remaining = maxf(0.0, flight_remaining - delta)
	if is_caught and state == GameState.PLAYING:
		caught_remaining -= delta
		if caught_remaining <= 0.0: _finish_game()
	if state == GameState.PLAYING:
		coworker.set_pose("talk" if target.state == TargetCoworker.CoworkerState.TALKING and not is_caught else "working")
		coworker.sprite.flip_h = target.state == TargetCoworker.CoworkerState.TALKING
		bubble.visible = target.can_be_stolen and not is_caught
		bubble.fraction = target.safe_fraction()
		bubble.queue_redraw()
		_update_hud()
	queue_redraw()

func _draw() -> void:
	if not is_node_ready(): return
	# Draw separate replaceable textures above the desk foreground.
	if target.has_banana:
		draw_texture_rect(BANANA_TEXTURE, Rect2(530, 326, 48, 40), false)
	if not target.stolen_this_event:
		draw_texture_rect(TASK_TEXTURE, Rect2(506, 350, 40, 32), false)
	# Three growing stacks; overflow counts remain visible in endless play.
	for i in range(mini(paper_count(), 180)):
		var column := i % 3
		var layer := i / 3
		draw_texture_rect(STACK_TEXTURE, Rect2(270 + column * 26, 365 - layer * 2, 30, 8), false)
	if paper_count() > 0:
		draw_string(FONT, Vector2(278, 404), "書類 %d" % paper_count(), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("f3ead1"))
	for i in range(mini(stolen_bananas, 60)):
		var column := i % 4
		var layer := i / 4
		draw_texture_rect(PEEL_TEXTURE, Rect2(90 + column * 17 + (layer % 2) * 5, 404 - layer * 5, 32, 26), false)
	if stolen_bananas > 0:
		draw_string(FONT, Vector2(92, 451), "皮 %d個" % stolen_bananas, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("f4cd55"))
	if flight_remaining > 0.0:
		var progress := 1.0 - flight_remaining / 0.42
		var x := lerpf(510, 283, progress)
		var y := 327.0 - sin(progress * PI) * 72.0
		draw_texture_rect(TASK_TEXTURE, Rect2(x, y, 48, 40), false)
		if flight_banana:
			draw_texture_rect(BANANA_TEXTURE, Rect2(x + 23, y - 30, 48, 40), false)
			for i in range(8):
				var angle := i * TAU / 8.0
				var p := Vector2(247, 291) + Vector2.from_angle(angle) * (20 + progress * 75)
				draw_rect(Rect2(p, Vector2(6, 6)), Color("f4cd55"))
	if state != GameState.PLAYING: return
	if is_caught:
		draw_rect(Rect2(391, 193, 180, 47), Color("b35d55"))
		draw_string(FONT, Vector2(410, 225), "もう辞める！" if quit_from_frustration else "見てたぞ！", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("fff0d2"))
	elif target.state == TargetCoworker.CoworkerState.PHONE:
		draw_rect(Rect2(428, 199, 168, 36), Color("dce4cd"))
		draw_string(FONT, Vector2(441, 224), "もしもし…", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("263e4d"))
	elif target.state == TargetCoworker.CoworkerState.TALKING:
		draw_rect(Rect2(525, 191, 174, 36), Color("dce4cd"))
		draw_string(FONT, Vector2(539, 216), "あの件だけど…", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("263e4d"))
