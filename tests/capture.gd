extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func snapshot(path: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)

func run() -> void:
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	root.size = Vector2i(960, 540)
	await snapshot("res://docs/title.png")
	var game = main.get_node("Game")
	game.scores.save_path = "user://capture_score.cfg"
	game.scores.high_score = 0
	main.get_node("TitleScreen").hide()
	game.start_game()
	game.target.has_banana = true
	game.target.begin_distraction(TargetCoworker.CoworkerState.PHONE)
	await snapshot("res://docs/gameplay.png")
	game.handle_enter()
	await create_timer(0.10).timeout
	await snapshot("res://docs/banana.png")
	await create_timer(0.30).timeout
	game.handle_enter()
	await create_timer(0.75).timeout
	await snapshot("res://docs/gameover.png")
	game.start_game()
	main.get_node("GameOver").hide()
	game.score = 10400
	game.scores.high_score = 10400
	game.stolen_bananas = 25
	game.missed_chances = 4
	game.target.apply_difficulty(game.score)
	game.target.begin_distraction(TargetCoworker.CoworkerState.TALKING)
	await snapshot("res://docs/hyper.png")
	game.target._process(game.target.window_duration + 0.01)
	await create_timer(0.75).timeout
	await snapshot("res://docs/quit.png")
	DirAccess.remove_absolute(game.scores.save_path)
	for player in game.get_node("Audio").get_children(): player.stop()
	await create_timer(0.2).timeout
	main.queue_free()
	await process_frame
	call_deferred("quit")
