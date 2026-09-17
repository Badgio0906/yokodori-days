extends Node

@onready var game: GameManager = $Game
@onready var title_screen = $TitleScreen
@onready var game_over_screen = $GameOver

func _ready() -> void:
	# Resolve input after the target has advanced and before the frame is drawn.
	process_priority = 100
	game.game_finished.connect(_on_game_finished)
	game_over_screen.hide()

func _process(_delta: float) -> void:
	# Godot ignores keyboard echo by default. Holding either Enter cannot repeat.
	if not Input.is_action_just_pressed("steal"): return
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
