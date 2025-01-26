extends Node

signal multiplier_changed(multiplier: float, info: Dictionary)
signal score_changed(score: int, info: Dictionary)
signal countdown_changed(countdown: int)
signal beat_changed(beat: int, next_beat: float)
signal game_over()

var multiplier: float = 1.0
var score: int = 0
var countdown_seconds: float = 5
var countdown: float = 0.0
var clock_enabled: bool = true

var balls: Array[Ball] = []

func _ready() -> void:
	reset()

	clock_enabled = true

func restart_game() -> void:
	reset()
	get_tree().reload_current_scene()
	clock_enabled = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if not event.is_pressed():
			return

		match event.keycode:
			KEY_R:
				restart_game()
			KEY_C:
				for ball in balls.duplicate():
					ball.explode()
				balls.clear()
			KEY_M:
				Game.add_multiplier(1.0, "cheater!")

func _process(delta: float) -> void:
	if clock_enabled:
		countdown -= delta
		countdown_changed.emit(countdown)

		if countdown <= 0.0:
			clock_enabled = false
			game_over.emit()

func reset_multiplier(reason: String) -> void:
	var old_multiplier = multiplier
	multiplier = 1.0
	multiplier_changed.emit(multiplier, { "reason" = reason, "sum" = (-old_multiplier + 1.0) })

	if old_multiplier > 1.0:
		FmodServer.play_one_shot("event:/miss-error")

func add_multiplier(value: float, reason: String) -> void:
	multiplier += value
	multiplier_changed.emit(multiplier, { "reason" = reason, "sum" = value })

func add_points(points: int, reason: String) -> void:
	var sum = int(points * multiplier) if points > 0 else int(points)

	if sum > 0:
		var aditional_seconds = (float(sum) / 500) * 3.0

		countdown += aditional_seconds
		countdown_changed.emit(countdown)
	
	score += sum
	score_changed.emit(score, { "reason" = reason, "sum" = sum })

	if score <= 0:
		clock_enabled = false
		game_over.emit()

func check_flying_balls() -> int:
	var stone = get_tree().root.get_node("Main Scene/Table/Stone")

	var ok_balls: Array[Ball] = stone.get_neighbors()
	var check_balls: Array[Ball] = ok_balls.duplicate()

	while check_balls.size() > 0:
		var ball = check_balls.pop_front()
		var neighbors = ball.get_neighbors()

		for neighbor in neighbors:
			if neighbor not in ok_balls:
				check_balls.append(neighbor)
			ok_balls.append(neighbor)

		check_balls.erase(ball)

	var total_deleted: int = 0
	for ball in balls.duplicate():
		if ball in ok_balls:
			continue

		ball.explode()
		total_deleted += 1

	if total_deleted > 0:
		add_points(total_deleted * 50, "explode " + str(total_deleted) + "x")
	
	return total_deleted

func reset() -> void:
	multiplier = 1.0
	score = 0
	countdown = countdown_seconds
	clock_enabled = false

	for ball in balls:
		ball.queue_free()

	balls.clear()
