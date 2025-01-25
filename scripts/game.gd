extends Node

signal multiplier_changed(multiplier: float, reason: String)
signal score_changed(score: int, reason: String)

var multiplier: float = 1.0
var score: int = 0

var balls: Array[Ball] = []

func reset_multiplier(reason: String) -> void:
	multiplier = 1.0
	multiplier_changed.emit(multiplier, reason)

func add_multiplier(value: float, reason: String) -> void:
	multiplier += value
	multiplier_changed.emit(multiplier, reason)

func add_points(points: int, reason: String) -> void:
	score += points * multiplier
	score_changed.emit(score, reason)

func reset() -> void:
	multiplier = 1.0
	score = 0

	balls.clear()