extends Control

@onready var multiplier_label: Label = $Multiplier
@onready var points_label: Label = $Points

func _ready() -> void:
	Game.multiplier_changed.connect(update_multiplier)
	Game.score_changed.connect(update_score)
	
	update_multiplier(Game.multiplier, {})
	update_score(Game.score, {})
	
func update_multiplier(multiplier: float, _info: Dictionary):
	multiplier_label.text = str(multiplier).pad_decimals(2) + "x"
	
func update_score(score: int, _info: Dictionary):
	points_label.text = str(score) + " pts"