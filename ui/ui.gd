extends Control

@export var style_reason: PackedScene

@onready var multiplier_label: Label = $Multiplier
@onready var points_label: Label = $Points
@onready var style_reason_container: BoxContainer = $StyleReasonContainer

func _ready() -> void:
	Game.multiplier_changed.connect(update_multiplier)
	Game.score_changed.connect(update_score)
	
	update_multiplier(Game.multiplier, {})
	update_score(Game.score, {})
	
func update_multiplier(multiplier: float, info: Dictionary):
	multiplier_label.text = str(multiplier).pad_decimals(2) + "x"

	if info.is_empty():
		return

	_create_style_reason(info["reason"], "+" + str(info["sum"]) + "x")
	
func update_score(score: int, info: Dictionary):
	points_label.text = str(score) + " pts"

	if info.is_empty():
		return

	_create_style_reason(info["reason"], ("+" if info["sum"] > 0 else "-") + str(info["sum"]) + "pts")

func _create_style_reason(reason: String, value: String) -> void:
	var style_reason_instance = style_reason.instantiate()

	style_reason_container.add_child(style_reason_instance)
	style_reason_instance.get_node("Reason").text = reason
	style_reason_instance.get_node("Value").text = value
	style_reason_container.move_child(style_reason_instance, 0)

	if style_reason_container.get_child_count() > 4:
		style_reason_container.get_child(4).queue_free()
