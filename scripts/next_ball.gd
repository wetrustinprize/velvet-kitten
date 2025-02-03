extends Node2D

@onready var ball: Ball = $Ball

func _ready():
	ball.update_info(Game.next_ball_info)

	Game.next_ball_changed.connect(on_next_ball_changed)

func on_next_ball_changed(next_ball_info: BallInfo) -> void:
	ball.update_info(next_ball_info)

