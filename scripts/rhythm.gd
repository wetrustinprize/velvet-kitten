extends Timer

@onready var table: Node2D = get_parent().get_node("Table")
@onready var paws: Paws = get_parent().get_node("Paws")

var beat: int = 1
var tween_duration: float = 0.1
var bpm = 140.0

func _ready() -> void:
	wait_time = 60.0 / bpm

	Game.multiplier_changed.connect(handle_multiplier_changed)

func handle_multiplier_changed(multiplier: float, _reason: String) -> void:
	if multiplier < 1.99:
		FmodServer.set_global_parameter_by_name("Phase", 0)
	elif multiplier < 2.99:
		FmodServer.set_global_parameter_by_name("Phase", 1)
	elif multiplier < 3.99:
		FmodServer.set_global_parameter_by_name("Phase", 2)
	else:
		FmodServer.set_global_parameter_by_name("Phase", 3)

func _on_timeout() -> void:
	var inverse: bool = beat % 2 == 0
	
	if beat == 3:
		beat = 0
		paws.hit()
	else:
		var tween: Tween = get_tree().create_tween()
		var rot = table.rotation_degrees + 45 * (-1 if inverse else 1)
		tween.tween_property(table, "rotation_degrees", rot, tween_duration).set_trans(Tween.TRANS_SPRING)
		beat += 1
		