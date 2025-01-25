extends Node

signal multiplier_changed(multiplier: float)
signal score_changed(score: int)

var _multiplier: float = 1.0
var multiplier: float :
	get:
		return _multiplier
	set(value):
		_multiplier = max(1.0, value)
		multiplier_changed.emit(_multiplier)

var _score: int = 0
var score: int :
	get:
		return _score
	set(value):
		_score = value
		score_changed.emit(_score)

var balls: Array[Ball] = []

func reset() -> void:
	multiplier = 1.0
	score = 0

	balls.clear()