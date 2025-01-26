extends CharacterBody2D
class_name Ball

@export var info: BallInfo = BallInfo.new()

@onready var sprite: Sprite2D = $Sprite
@onready var smoke: AnimatedSprite2D = $Smoke
@onready var shape_cast: ShapeCast2D = $ShapeCast
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	update_info(info)

func update_info(new_info: BallInfo) -> void:
	info = new_info

	sprite.modulate = Color.WHITE
	if info.type != BallInfo.TYPE.BLACK:
		sprite.texture = load("res://graphics/outer_ball/%s.png" % info.type)

	match info.type:
		BallInfo.TYPE.BLACK:
			sprite.modulate = Color.BLACK
			smoke.modulate = Color.BLACK
		BallInfo.TYPE.GREEN:
			smoke.modulate = Color.GREEN
		BallInfo.TYPE.RED:
			smoke.modulate = Color.RED
		BallInfo.TYPE.YELLOW:
			smoke.modulate = Color.YELLOW
		BallInfo.TYPE.PURPLE:
			smoke.modulate = Color.PURPLE
		BallInfo.TYPE.BLUE:
			smoke.modulate = Color.BLUE

func get_neighbors() -> Array[Ball]:
	shape_cast.force_shapecast_update()

	var neighbors: Array[Ball] = []

	for i in shape_cast.get_collision_count():
		var neighbor = shape_cast.get_collider(i)

		if neighbor.is_queued_for_deletion():
			continue

		if neighbor is Ball:
			neighbors.append(neighbor)

	return neighbors

# gets the full line of balls of the same color
func get_match_line(ignore: Array[Ball] = []) -> Array[Ball]:
	var match_line: Array[Ball] = []

	match_line.append(self)
	ignore.append(self)

	for neighbor in get_neighbors():
		if neighbor.info.type != info.type:
			continue

		if neighbor in ignore:
			continue

		match_line.append(neighbor)

		ignore.append(neighbor)
		match_line.append_array(neighbor.get_match_line(ignore))

	# remove duplicates
	for ball in match_line:
		if match_line.count(ball) > 1:
			match_line.erase(ball)

	return match_line

func check_neighbors() -> void:
	match info.type:
		_:
			handle_default()

	Game.check_flying_balls()

func explode() -> void:
	Game.balls.erase(self)

	collision_layer = 0
	collision_mask = 0
	animation_player.play("explode")
	z_index = 0

func handle_default() -> void:
	var match_line = get_match_line()
	var match_total = match_line.size()

	if match_line.size() > 2:
		for ball in match_line:
			ball.explode()

	match match_total:
		3:
			Game.add_points(300, "triplet")
			Game.add_multiplier(0.1, "triplet")
		4:
			Game.add_points(400, "quadruplet")
			Game.add_multiplier(0.2, "quadruplet")
		5:
			Game.add_points(700, "quintuplet")
			Game.add_multiplier(0.3, "quintuplet")
