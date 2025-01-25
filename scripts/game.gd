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

func _process(_delta: float) -> void:
	check_flying_balls()

func check_flying_balls() -> void:
	var stone = get_tree().root.get_node("Main Scene/Table/Stone")

	var ignores: Array[Ball] = [ stone ]
	var check: Array[Ball] = stone.get_neighbors()

	while check.size() > 0:
		var ball = check.pop_front()

		if ball in ignores:
			continue

		ignores.append(ball)
		check.append_array(ball.get_neighbors())

	var total_deleted: int = 0
	for ball in balls:
		if ball in ignores:
			continue

		balls.erase(ball)
		ball.queue_free()
		total_deleted += 1

	if total_deleted > 0:
		add_points(total_deleted * 50, "explode")


func reset() -> void:
	multiplier = 1.0
	score = 0

	for ball in balls:
		ball.queue_free()

	balls.clear()
