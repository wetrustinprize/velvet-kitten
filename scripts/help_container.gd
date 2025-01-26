extends Control

@onready var counter: Label = $Counter
@onready var scoreboard: Scoreboard = get_parent().get_node("ScoreboardText")

var hide_tween: bool = false

func _ready() -> void:
	Game.beat_changed.connect(handle_beat_changed)
	Game.multiplier_changed.connect(handle_multiplier_changed)
	Game.score_changed.connect(handle_score_changed)
	scoreboard.modulate.a = 0.0

func handle_beat_changed(beat: int, _next_beat: float) -> void:
	match beat:
		0:
			counter.text = "3..."
		1:
			counter.text = "2.."
		2:
			counter.text = "1."
		3:
			counter.text = "NOW!"

func handle_multiplier_changed(_multiplier: float, info: Dictionary) -> void:
	if info["sum"] <= 0:
		return

	if hide_tween:
		return
	hide_tween = true
	animate_hide()

func handle_score_changed(_score: int, info: Dictionary) -> void:
	if info["sum"] <= 0:
		return

	if hide_tween:
		return
	hide_tween = true
	animate_hide()

func animate_hide() -> void:
	var hide_tween: Tween = get_tree().create_tween()
	hide_tween.tween_property(self, "modulate:a", 0.0, 0.1)

	var show_tween: Tween = get_tree().create_tween()
	show_tween.tween_property(scoreboard, "modulate:a", 1.0, 0.1)
