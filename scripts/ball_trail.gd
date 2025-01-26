extends Line2D

@export var trail_duration: float = 0.15

func _ready() -> void:
	clear_points()

func setup(new_points: Array[Vector2]) -> void:
	clear_points()

	for point in new_points:
		add_point(point)

	var tween = get_tree().create_tween()
	tween.tween_property(self, "width", 0.0, trail_duration)
	tween.tween_callback(queue_free)
