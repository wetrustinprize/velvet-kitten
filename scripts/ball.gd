extends CharacterBody2D
class_name Ball

@export var info: BallInfo = BallInfo.new()

@onready var sprite: Sprite2D = $Sprite
@onready var shape_cast: ShapeCast2D = $ShapeCast

func _ready() -> void:
	update_info(info)

func update_info(new_info: BallInfo) -> void:
	info = new_info

	# HACK: Just changing the colors
	match info.type:
		BallInfo.TYPE.BLACK:
			sprite.modulate = Color.BLACK
		BallInfo.TYPE.GREEN:
			sprite.modulate = Color.GREEN
		BallInfo.TYPE.YELLOW:
			sprite.modulate = Color.YELLOW
		BallInfo.TYPE.PURPLE:
			sprite.modulate = Color.PURPLE
		BallInfo.TYPE.BLUE:
			sprite.modulate = Color.BLUE

func get_neighbors() -> Array[Ball]:
	shape_cast.force_shapecast_update()

	var neighbors: Array[Ball] = []

	for i in shape_cast.get_collision_count():
		var neighbor = shape_cast.get_collider(i)

		if neighbor is Ball:
			neighbors.append(neighbor)

	return neighbors

# gets the full line of balls of the same color
func get_match_line(ignore: Array[Ball] = []) -> Array[Ball]:
	var match_line: Array[Ball] = []

	match_line.append(self)

	for neighbor in get_neighbors():
		if neighbor.info.type != info.type:
			continue

		if neighbor in ignore:
			continue

		match_line.append(neighbor)

		var new_ignore: Array[Ball] = ignore.duplicate()
		new_ignore.append(self)

		match_line.append_array(neighbor.get_match_line(new_ignore))

	# remove duplicates
	for ball in match_line:
		if match_line.count(ball) > 1:
			match_line.erase(ball)

	return match_line

func check_neighbors() -> void:
	match info.type:
		_:
			handle_default()


func handle_default() -> void:
	var match_line = get_match_line()

	if match_line.size() > 2:
		for ball in match_line:
			ball.queue_free()