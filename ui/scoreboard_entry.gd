extends TextureRect
class_name ScoreboardEntry

@onready var first_place_label_settings: LabelSettings = preload("res://ui/style_scoreboard/first_place.tres")
@onready var second_third_place_label_settings: LabelSettings = preload("res://ui/style_scoreboard/second_third_place.tres")
@onready var forward_place_label_settings: LabelSettings = preload("res://ui/style_scoreboard/forward_place.tres")
@onready var local_place_label_settings: LabelSettings = preload("res://ui/style_scoreboard/local_place.tres")

@onready var position_label: Label = %Position
@onready var name_label: Label = %Name
@onready var score_label: Label = %Score

func set_info(info: Dictionary) -> void:
	position_label.text = str(info.position)
	name_label.text = info.name
	score_label.text = str(info.score)
	self_modulate = Color.WHITE if info.local else Color.TRANSPARENT

	if info.local:
		position_label.label_settings = local_place_label_settings
		name_label.label_settings = local_place_label_settings
		score_label.label_settings = local_place_label_settings

		var blink_tween = create_tween()
		blink_tween.tween_property(self, "modulate:a", 0.5, 0.05)
		blink_tween.tween_interval(1)
		blink_tween.tween_property(self, "modulate:a", 1, 0.05)
		blink_tween.tween_interval(1)
		blink_tween.set_loops(0)
	elif info.position == 1:
		position_label.label_settings = first_place_label_settings
		name_label.label_settings = first_place_label_settings
		score_label.label_settings = first_place_label_settings
	elif info.position == 2 or info.position == 3:
		position_label.label_settings = second_third_place_label_settings
		name_label.label_settings = second_third_place_label_settings
		score_label.label_settings = second_third_place_label_settings
	else:
		position_label.label_settings = forward_place_label_settings
		name_label.label_settings = forward_place_label_settings
		score_label.label_settings = forward_place_label_settings


