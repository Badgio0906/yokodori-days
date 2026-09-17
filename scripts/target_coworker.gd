class_name TargetCoworker
extends CharacterVisual

signal steal_window_started
signal steal_window_ended
signal caught_player
signal task_stolen
signal banana_stolen
signal distraction_started(kind: int)
signal chance_missed

enum CoworkerState { WORKING, PHONE, TALKING, DISTRACTED, RETURNING }
const BANANA_CHANCE: float = 0.25
@export_range(0.0, 1.0) var banana_chance: float = BANANA_CHANCE
@export var min_work_time: float = 2.0
@export var max_work_time: float = 4.0
@export var distraction_duration: float = 2.1
@export var safe_window: float = 1.4
@export var short_window_scale: float = 0.65
var return_duration: float = 0.25
var events_until_short: int = 3
var short_chance: bool = false

var state: CoworkerState = CoworkerState.WORKING
var has_banana: bool = false
var can_be_stolen: bool = false
var active: bool = false
var elapsed: float = 0.0
var state_duration: float = 0.0
var window_duration: float = 0.0
var stolen_this_event: bool = false
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func reset() -> void:
	active = true
	events_until_short = rng.randi_range(2, 4)
	short_chance = false
	_enter_working()

func apply_difficulty(score: int) -> void:
	var values := DifficultyManager.settings(score)
	min_work_time = values.min_work_time
	max_work_time = values.max_work_time
	safe_window = values.safe_window
	distraction_duration = values.distraction_duration
	return_duration = values.return_duration

func _enter_working() -> void:
	_close_window()
	state = CoworkerState.WORKING
	elapsed = 0.0
	state_duration = rng.randf_range(min_work_time, max_work_time)
	has_banana = rng.randf() < banana_chance
	stolen_this_event = false
	set_pose("working")

func begin_distraction(kind: CoworkerState) -> void:
	state = kind
	elapsed = 0.0
	events_until_short -= 1
	short_chance = events_until_short <= 0
	if short_chance: events_until_short = rng.randi_range(2, 4)
	window_duration = safe_window * (short_window_scale if short_chance else 1.0)
	# The animation duration is independent of the safe window, with a visible return.
	state_duration = maxf(distraction_duration, window_duration + return_duration)
	can_be_stolen = true
	stolen_this_event = false
	set_pose("phone" if kind == CoworkerState.PHONE else "talk")
	distraction_started.emit(kind)
	steal_window_started.emit()

func _close_window() -> void:
	if can_be_stolen:
		can_be_stolen = false
		steal_window_ended.emit()

func attempt_steal() -> void:
	if not active: return
	if not can_be_stolen:
		active = false
		set_pose("caught")
		caught_player.emit()
		return
	var banana := has_banana
	stolen_this_event = true
	has_banana = false
	_close_window()
	task_stolen.emit()
	if banana: banana_stolen.emit()

func safe_fraction() -> float:
	if not can_be_stolen: return 0.0
	return clampf(1.0 - elapsed / window_duration, 0.0, 1.0)

func _process(delta: float) -> void:
	super._process(delta)
	if not active: return
	elapsed += delta
	if state == CoworkerState.WORKING:
		if elapsed >= state_duration:
			begin_distraction(CoworkerState.PHONE if rng.randf() < 0.5 else CoworkerState.TALKING)
	else:
		if elapsed >= window_duration and state != CoworkerState.RETURNING:
			var missed := can_be_stolen and not stolen_this_event
			_close_window()
			state = CoworkerState.RETURNING
			set_pose("working")
			if missed: chance_missed.emit()
			if not active: return
		if elapsed >= state_duration: _enter_working()
