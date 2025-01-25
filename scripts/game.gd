extends Node

var multiplier: float = 1.0
var balls: Array[Ball] = []

func reset() -> void:
	multiplier = 1.0
	balls.clear()
