extends Control

@export var style_reason: PackedScene

@onready var multiplier_label: Label = $Multiplier
@onready var points_label: Label = $Points
@onready var countdown_label: Label = $Countdown
@onready var style_reason_container: BoxContainer = $StyleReasonContainer

func _ready() -> void:
	Game.multiplier_changed.connect(update_multiplier)
	Game.score_changed.connect(update_score)
	Game.countdown_changed.connect(update_countdown)

	update_multiplier(Game.multiplier, {})
	update_score(Game.score, {})
	update_countdown(Game.countdown)

func update_countdown(countdown: float) -> void:
	var minutes = int(countdown) / 60
	var seconds = int(countdown) % 60

	countdown_label.text = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)

func update_multiplier(multiplier: float, info: Dictionary):
	multiplier_label.text = str(multiplier).pad_decimals(2) + "x"

	if info.is_empty():
		return

	if info["reason"] == "miss" or info["reason"] == "out of bounds":
		_create_style_reason(info["reason"], "reset")
		return

	_create_style_reason(info["reason"], "+" + str(info["sum"]) + "x")
	
func update_score(score: int, info: Dictionary):
	points_label.text = str(score)

	if info.is_empty():
		return

	_create_style_reason(info["reason"], ("+" if info["sum"] > 0 else "") + str(info["sum"]) + "pts")

func _create_style_reason(reason: String, value: String) -> void:
	var style_reason_instance = style_reason.instantiate()

	style_reason_container.add_child(style_reason_instance)
	style_reason_instance.get_node("Reason").text = reason
	style_reason_instance.get_node("Value").text = value
	style_reason_container.move_child(style_reason_instance, 0)

	if style_reason_container.get_child_count() > 4:
		style_reason_container.get_child(4).queue_free()
