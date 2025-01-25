extends Node2D

@export var paw_speed: float = 150.0
@export var max_rotation_deg: float = 45.0
@export var raycast_max_bounces: int = 3
@export var raycast_max_distance: float = 1000.0

@onready var line: Line2D = $Line
@onready var raycast_origin: Node2D = $RayCastOrigin
@onready var raycast: RayCast2D = $RayCastOrigin/RayCast2D
@onready var initial_target_position: Vector2 = Vector2.ZERO

var mouse_sensitivity: float = 0.01
var desired_rotation: float = 0.0

func _ready() -> void:
	initial_target_position = Vector2(0, -raycast_max_distance)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			hit(raycast_origin.position, initial_target_position)

	if event is InputEventMouseMotion:
		var x_diff = event.relative.x

		desired_rotation += x_diff * mouse_sensitivity
		desired_rotation = clamp(desired_rotation, -deg_to_rad(max_rotation_deg), deg_to_rad(max_rotation_deg))

func _process(delta: float) -> void:
	rotation = lerpf(rotation, desired_rotation, paw_speed * delta)

	line.clear_points()
	line.add_point(raycast_origin.position)
	hit(raycast_origin.position, initial_target_position)

func hit(new_position: Vector2, target_position: Vector2, current_bounces: int = 0) -> Object:
	if current_bounces >= raycast_max_bounces:
		return null

	raycast.position = new_position
	raycast.target_position = target_position
	raycast.force_raycast_update()
    
	if raycast.is_colliding():
		var collider = raycast.get_collider()

		var hit_position = raycast.get_collision_point()
		line.add_point(to_local(hit_position))

		if collider is Node:
			if collider.is_in_group("bounce"):
				var hit_normal = raycast.get_collision_normal()

				var new_hit_position = hit_position + (hit_normal * raycast_max_distance)

				return hit(raycast_origin.to_local(hit_position), raycast.to_local(new_hit_position), current_bounces + 1)
			else:
				return collider

	return null
