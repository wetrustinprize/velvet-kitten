extends Node2D

@onready var body: Sprite2D = $Body
@onready var head: Sprite2D = $Head

var head_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	Game.beat_changed.connect(handle_beat_changed)

	head_position = head.position

func handle_beat_changed(beat: int, next_beat: float) -> void:
	body.scale.y = 0.98
	head.position = head_position - Vector2.DOWN * -(12 if beat == 3 else 4)

	var body_tween: Tween = get_tree().create_tween()
	body_tween.tween_property(body, "scale:y", 1.0, next_beat - 0.05)

	var head_tween: Tween = get_tree().create_tween()
	head_tween.tween_property(head, "position:y", head_position.y, next_beat - 0.05)
