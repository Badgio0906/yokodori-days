extends SceneTree

var failures: int = 0
var main: Node
var game: GameManager

func check(condition: bool, message: String) -> void:
	if condition: print("PASS: ", message)
	else:
		push_error("FAIL: " + message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func press(key: Key = KEY_ENTER, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.pressed = true
	event.echo = echo
	Input.parse_input_event(event)
	await process_frame
	await process_frame

func release(key: Key = KEY_ENTER) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame
	await process_frame

func tap(position: Vector2 = Vector2(480, 270)) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = position
	event.pressed = true
	main._input(event)
	await process_frame
	await process_frame

func run() -> void:
	main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	game = main.get_node("Game")
	# Do not overwrite the player's actual best score during tests.
	game.scores.save_path = "user://test_high_score.cfg"
	game.scores.high_score = 0
	check(game.state == GameManager.GameState.TITLE, "Initial title")
	check(InputMap.action_has_event("steal", key_event(KEY_ENTER)), "Enter InputMap")
	check(InputMap.action_has_event("steal", key_event(KEY_KP_ENTER)), "Numpad Enter InputMap")
	await tap()
	check(game.state == GameManager.GameState.PLAYING, "Tap starts play")
	check(not game.is_caught and game.score == 0, "Start tap does not steal")
	await create_timer(0.15).timeout
	game.target.has_banana = false
	game.target.begin_distraction(TargetCoworker.CoworkerState.PHONE)
	await process_frame
	check(game.bubble.visible and game.target.can_be_stolen, "Phone opens matching bubble and safe window")
	await tap(Vector2(18, 520))
	check(game.score == 100 and game.stolen_tasks == 1, "Tap steals task +100")
	check(not game.target.can_be_stolen and not game.bubble.visible, "Success closes window immediately")
	await press(KEY_ENTER, true)
	check(game.score == 100 and not game.is_caught, "Key echo is ignored after a tap")
	# A mirrored mobile touch must not apply a second action.
	await tap(Vector2(18, 520))
	check(game.score == 100 and not game.is_caught, "Touch debounce prevents duplicate action")
	await press()
	check(game.score == 100 and not game.is_caught, "Short input lock prevents duplicate score")
	await release()
	await create_timer(0.24).timeout
	game.target.has_banana = true
	game.target.begin_distraction(TargetCoworker.CoworkerState.TALKING)
	await press()
	check(game.score == 500 and game.stolen_bananas == 1, "Talking steals task plus banana +400")
	check(not game.target.has_banana and game.popup.banana, "Banana consumed and special feedback")
	await create_timer(0.3).timeout
	await press(KEY_ENTER, true)
	check(game.score == 500 and not game.is_caught, "Holding Enter cannot repeat after lock")
	await release()
	var saved := HighScoreManager.new()
	saved.save_path = game.scores.save_path
	saved.load_score()
	check(saved.high_score == 500, "Best score persists via user://")
	# A new deliberate press outside a chance is fatal, even after success.
	await press()
	check(game.is_caught, "Second deliberate press outside window is caught")
	await release()
	await create_timer(0.75).timeout
	check(game.state == GameManager.GameState.GAME_OVER, "Caught animation leads to game over")
	check(main.get_node("GameOver").visible and main.get_node("GameOver").new_record, "Results and NEW RECORD")
	await press()
	check(game.state == GameManager.GameState.PLAYING and game.score == 0, "Enter restarts immediately")
	check(game.scores.high_score == 500 and game.stolen_tasks == 0, "Restart retains high and resets run")
	await release()
	game.target.safe_window = 0.05
	game.target.distraction_duration = 0.5
	game.target.begin_distraction(TargetCoworker.CoworkerState.PHONE)
	await create_timer(0.1).timeout
	check(not game.target.can_be_stolen and not game.bubble.visible, "Expired safe window closes bubble")
	check(game.target.state == TargetCoworker.CoworkerState.RETURNING, "Animation return outlasts safety")
	await press()
	check(game.is_caught, "Expired chance fails")
	await release()
	game.start_game()
	await press()
	check(game.is_caught, "Working state fails")
	await release()
	var easy := DifficultyManager.settings(0)
	var hard := DifficultyManager.settings(10000)
	check(easy.safe_window > hard.safe_window and hard.safe_window >= 0.42, "Difficulty shrinks safety with a lower bound")
	check(easy.min_work_time > hard.min_work_time, "Difficulty speeds cadence")
	game.start_game()
	game.target.rng.seed = 12345
	game.target.distraction_started.disconnect(game._on_distraction)
	var phones := 0
	var talks := 0
	var bananas := 0
	var waits: Dictionary = {}
	for i in range(200):
		game.target.reset()
		bananas += int(game.target.has_banana)
		waits[snappedf(game.target.state_duration, 0.01)] = true
		game.target._process(5.0)
		phones += int(game.target.state == TargetCoworker.CoworkerState.PHONE)
		talks += int(game.target.state == TargetCoworker.CoworkerState.TALKING)
	check(phones > 40 and talks > 40 and waits.size() > 20, "Random phone/talk events and nonperiodic waits")
	check(bananas > 20 and bananas < 85, "Bananas randomly spawn near configured 25%")
	game.start_game()
	var short_count := 0
	var gap := 0
	var bounded_gaps := true
	for i in range(40):
		game.target.begin_distraction(TargetCoworker.CoworkerState.PHONE)
		gap += 1
		if game.target.short_chance:
			short_count += 1
			bounded_gaps = bounded_gaps and gap >= 2 and gap <= 4
			gap = 0
			check(is_equal_approx(game.target.window_duration, game.target.safe_window * 0.65), "Short window multiplier")
	check(short_count >= 10 and bounded_gaps, "One short event every 2-4 chances")
	var hyper := DifficultyManager.settings(10001)
	var pressure := 1.0 - exp(-10001.0 / DifficultyManager.DIFFICULTY_SCORE_SCALE)
	check(is_equal_approx(hyper.min_work_time, lerpf(2.0, 0.7, pressure) * 0.5), "Hyper halves wait time")
	check(is_equal_approx(hyper.distraction_duration, lerpf(2.1, 0.95, pressure) * 0.5), "Hyper halves event time for twice the frequency")
	check(hyper.safe_window < 0.23 and hard.safe_window > 0.42, "Hyper strictly above 10000 with ultra-short safety")
	game.start_game()
	game.target.has_banana = false
	game.target.begin_distraction(TargetCoworker.CoworkerState.TALKING)
	game.handle_enter()
	game.target._process(game.target.window_duration + 0.01)
	check(game.missed_chances == 0, "Successful event never increases gauge")
	for i in range(GameManager.MISSES_TO_QUIT):
		game.target.begin_distraction(TargetCoworker.CoworkerState.PHONE)
		game.target._process(game.target.window_duration + 0.01)
		check(game.missed_chances == i + 1, "One gauge increment per missed event")
		game.target._process(0.01)
		check(game.missed_chances == i + 1, "No double counting expiry")
	check(game.is_caught and game.quit_from_frustration and not game.target.active, "Full gauge stops play with quit reason")
	await create_timer(0.75).timeout
	check(game.state == GameManager.GameState.GAME_OVER and main.get_node("GameOver").quit_from_frustration, "Quit reason reaches result screen")
	await press()
	await release()
	check(game.missed_chances == 0 and not game.quit_from_frustration, "Restart clears gauge and reason")
	game.score = 10400
	game.stolen_bananas = 25
	check(game.paper_count() == 104, "Paper stacks follow total score including banana points")
	game.start_game()
	check(game.paper_count() == 0 and game.stolen_bananas == 0, "Restart clears paper and peel counts")
	game.target.active = false
	for player in game.get_node("Audio").get_children(): player.stop()
	await create_timer(0.2).timeout
	DirAccess.remove_absolute(game.scores.save_path)
	print("RESULT: ", "ALL TESTS PASSED" if failures == 0 else str(failures) + " FAILED")
	main.queue_free()
	await process_frame
	call_deferred("quit", 1 if failures else 0)

func key_event(key: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = key
	return event
