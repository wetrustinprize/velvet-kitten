extends Node2D

@onready var body: Sprite2D = $Body
@onready var head: Sprite2D = $Head

@export var head_normal: Texture2D
@export var head_sad: Texture2D

var head_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	Game.beat_changed.connect(handle_beat_changed)
	Game.game_over.connect(handle_game_over)
	Game.multiplier_changed.connect(handle_multiplier_changed)

	head_position = head.position

func handle_game_over() -> void:
	head.texture = head_sad

func handle_multiplier_changed(_multiplier: int, info: Dictionary) -> void:
	if info["reason"] == "miss" or info["reason"] == "out of bounds" or info["sum"] < 0:
		head.texture = head_sad

func handle_beat_changed(beat: int, next_beat: float) -> void:
	head.texture = head_normal

	body.scale.y = 0.98
	head.position = head_position - Vector2.DOWN * -(12 if beat == 3 else 4)

	var body_tween: Tween = get_tree().create_tween()
	body_tween.tween_property(body, "scale:y", 1.0, next_beat - 0.05)

	var head_tween: Tween = get_tree().create_tween()
	head_tween.tween_property(head, "position:y", head_position.y, next_beat - 0.05)
