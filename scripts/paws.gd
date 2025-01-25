extends Node2D
class_name Paws

@export var paw_speed: float = 150.0
@export var max_rotation_deg: float = 45.0
@export var raycast_max_bounces: int = 3
@export var raycast_max_distance: float = 2000.0

@onready var ball: Ball = $Ball
@onready var line: Line2D = $Line
@onready var raycast_origin: Node2D = $RayCastOrigin
@onready var raycast: RayCast2D = $RayCastOrigin/RayCast2D
@onready var initial_target_position: Vector2 = Vector2.ZERO
@onready var ball_scene: PackedScene = preload("res://ball.tscn")

@onready var ball_info: BallInfo = BallInfo.random()

var mouse_sensitivity: float = 0.001
var desired_rotation: float = 0.0

func _ready() -> void:
	initial_target_position = Vector2(0, -raycast_max_distance)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	ball.update_info(ball_info)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var x_diff = event.relative.x

		desired_rotation += x_diff * mouse_sensitivity
		desired_rotation = clamp(desired_rotation, -deg_to_rad(max_rotation_deg), deg_to_rad(max_rotation_deg))

func _process(delta: float) -> void:
	rotation = lerpf(rotation, desired_rotation, paw_speed * delta)

	line.clear_points()
	line.add_point(raycast_origin.position)
	calculate_hit(raycast_origin.position, initial_target_position)

func hit() -> void:
	var result = calculate_hit(raycast_origin.position, initial_target_position)

	if result.is_empty() or result.collider is not Ball:
		return

	var new_ball = ball_scene.instantiate()
	Game.balls.append(new_ball)
	var table: Node2D = get_parent().get_node("Table")

	table.add_child(new_ball)
	new_ball.update_info(ball_info)

	var pos = result.collider.global_position
	pos += result.hit_normal.normalized() * 110

	new_ball.position = table.to_local(pos)
	new_ball.check_neighbors()

	ball_info = BallInfo.random()
	ball.update_info(ball_info)

func calculate_hit(new_position: Vector2, target_position: Vector2, current_bounces: int = 0) -> Dictionary:
	if current_bounces >= raycast_max_bounces + 1:
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
				return {
					"collider": collider,
					"hit_position": hit_position,
					"hit_normal": hit_normal
				}

	return {}
