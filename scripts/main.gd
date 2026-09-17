extends Node

@onready var game: GameManager = $Game
@onready var title_screen = $TitleScreen
@onready var game_over_screen = $GameOver
const TOUCH_DEBOUNCE_SECONDS: float = 0.12
var touch_debounce: float = 0.0

func _ready() -> void:
	# Resolve input after the target has advanced and before the frame is drawn.
	process_priority = 100
	game.game_finished.connect(_on_game_finished)
	game_over_screen.hide()

func _process(delta: float) -> void:
	touch_debounce = maxf(0.0, touch_debounce - delta)
	# Godot ignores keyboard echo by default. Holding either Enter cannot repeat.
	if not Input.is_action_just_pressed("steal"): return
	activate_action()

func _input(event: InputEvent) -> void:
	# A tap on the Godot Web canvas uses the exact same state-dependent action as Enter.
	# The short gate absorbs duplicate browser touch events without changing keyboard input.
	if event is InputEventScreenTouch and event.pressed:
		if touch_debounce > 0.0: return
		touch_debounce = TOUCH_DEBOUNCE_SECONDS
		activate_action()
		get_viewport().set_input_as_handled()

func activate_action() -> void:
	match game.state:
		GameManager.GameState.TITLE, GameManager.GameState.GAME_OVER:
			title_screen.hide()
			game_over_screen.hide()
			game.start_game()
		GameManager.GameState.PLAYING:
			game.handle_enter()

func _on_game_finished(final_score: int, high: int, record: bool) -> void:
	game_over_screen.score = final_score
	game_over_screen.high = high
	game_over_screen.new_record = record
	game_over_screen.quit_from_frustration = game.quit_from_frustration
	game_over_screen.show()
	game_over_screen.queue_redraw()
