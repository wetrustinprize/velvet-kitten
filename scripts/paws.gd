extends Node2D
class_name Paws

@export var max_rotation_deg: float = 45.0
@export var raycast_max_bounces: int = 3
@export var raycast_max_distance: float = 2000.0

@onready var ball: Ball = $Ball
@onready var line: Line2D = $Line
@onready var hit_indicator: Sprite2D = $HitIndicator
@onready var raycast_origin: Node2D = $RayCastOrigin
@onready var raycast: RayCast2D = $RayCastOrigin/RayCast2D
@onready var initial_target_position: Vector2 = Vector2.ZERO

@onready var ball_scene: PackedScene = preload("res://ball.tscn")
@onready var ball_trail_scene: PackedScene = preload("res://ball_trail.tscn")
@onready var hit_shake_preset: ShakerPreset2D = preload("res://camera_hit_shake.tres")
@onready var miss_shake_preset: ShakerPreset2D = preload("res://camera_miss_shake.tres")

@onready var ball_info: BallInfo = BallInfo.random()

var can_aim: bool = true

func _ready() -> void:
	initial_target_position = Vector2(0, -raycast_max_distance)
	ball.update_info(ball_info)
	Game.game_over.connect(on_game_over)

func on_game_over() -> void:
	can_aim = false

func _input(event: InputEvent) -> void:
	if not can_aim:
		return

	if event is InputEventMouseMotion:
		look_at(get_global_mouse_position())
		rotation += deg_to_rad(90)
		rotation = clamp(rotation, -deg_to_rad(max_rotation_deg), deg_to_rad(max_rotation_deg))

func _process(_delta: float) -> void:
	line.clear_points()
	line.add_point(raycast_origin.position)
	calculate_hit(raycast_origin.position, initial_target_position)

func update_ball_info(new_ball_info: BallInfo) -> void:
	ball_info = new_ball_info
	ball.update_info(ball_info)

func hit() -> bool:
	Game.clock_enabled = true

	var camera = get_viewport().get_camera_2d()
	var result = calculate_hit(raycast_origin.position, initial_target_position)

	if result.is_empty() or result.collider is not Ball:
		Shaker.shake_by_preset(miss_shake_preset, camera, 0.1)
		return false

	var new_ball = ball_scene.instantiate()
	var table: Node2D = get_parent().get_node("Table")

	table.add_child(new_ball)
	new_ball.update_info(ball_info)

	var pos = result.collider.global_position
	pos += result.hit_normal.normalized() * 110

	new_ball.position = table.to_local(pos)
	update_ball_info(Game.next_ball_info)
	Game.next_ball()

	var new_ball_pos = abs(new_ball.position.y) + abs(new_ball.position.x)
	if new_ball_pos > 530:
		new_ball.queue_free()
		Shaker.shake_by_preset(miss_shake_preset, camera, 0.1)
		return false

	Game.balls.append(new_ball)
	new_ball.animation_player.play("spawn")
	new_ball.check_neighbors()

	Shaker.shake_by_preset(hit_shake_preset, camera, 0.1)

	var ball_trail = ball_trail_scene.instantiate()

	var ball_trail_points: Array[Vector2] = []
	for point in line.points:
		ball_trail_points.append(point)

	get_tree().root.add_child(ball_trail)
	ball_trail.rotation = rotation
	ball_trail.position = line.global_position
	ball_trail.setup(ball_trail_points)

	return true

func calculate_hit(new_position: Vector2, target_position: Vector2, current_bounces: int = 0) -> Dictionary:
	if current_bounces >= raycast_max_bounces + 1:
		line.modulate = Color.RED
		hit_indicator.visible = false
		return {}

	raycast.position = new_position
	raycast.target_position = target_position
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()

		var hit_position = raycast.get_collision_point()
		var hit_normal = raycast.get_collision_normal()
		line.add_point(to_local(hit_position))

		if collider is Node:
			if collider.is_in_group("bounce"):

				var new_hit_position = hit_position + (hit_normal * raycast_max_distance)
				return calculate_hit(raycast_origin.to_local(hit_position), raycast.to_local(new_hit_position), current_bounces + 1)
			else:
				line.modulate = Color(1.0, 1.0, 1.0, 0.5)
				hit_indicator.visible = true
				hit_indicator.position = to_local(hit_position)

				return {
					"collider": collider,
					"hit_position": hit_position,
					"hit_normal": hit_normal
				}

	line.modulate = Color.RED
	hit_indicator.visible = false
	return {}
