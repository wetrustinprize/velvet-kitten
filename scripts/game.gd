extends Node

signal multiplier_changed(multiplier: float, info: Dictionary)
signal score_changed(score: int, info: Dictionary)

var multiplier: float = 1.0
var score: int = 0

var balls: Array[Ball] = []

func reset_multiplier(reason: String) -> void:
	var old_multiplier = multiplier
	multiplier = 1.0
	multiplier_changed.emit(multiplier, { "reason" = reason, "sum" = (-old_multiplier + 1.0) })

func add_multiplier(value: float, reason: String) -> void:
	multiplier += value
	multiplier_changed.emit(multiplier, { "reason" = reason, "sum" = value })

func add_points(points: int, reason: String) -> void:
	score += points * multiplier
	score_changed.emit(score, { "reason" = reason, "sum" = points })

func check_flying_balls() -> void:
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

		balls.erase(ball)
		ball.queue_free()
		total_deleted += 1

	if total_deleted > 0:
		add_points(total_deleted * 50, "explode " + str(total_deleted))


func reset() -> void:
	multiplier = 1.0
	score = 0

	for ball in balls:
		ball.queue_free()

	balls.clear()
