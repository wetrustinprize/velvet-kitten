extends Timer

@export var buffer_time: float = 0.2

@onready var table: Node2D = get_parent().get_node("Table")
@onready var paws: Paws = get_parent().get_node("Paws")

var disable_hit: bool = false
var can_hit: bool = false

var beat: int = 1
var stage: int = 0
var tween_duration: float = 0.1
var bpm = 140.0

func _ready() -> void:
	wait_time = 60.0 / bpm
	Game.multiplier_changed.connect(handle_multiplier_changed)
	Game.game_over.connect(_on_game_over)

func handle_multiplier_changed(multiplier: float, _info: Dictionary) -> void:
	var old_stage = stage

	if multiplier < 1.99:
		stage = 0
	elif multiplier < 2.99:
		stage = 1
	elif multiplier < 3.99:
		stage = 2
	else:
		stage = 3

	if old_stage < stage:
		FmodServer.play_one_shot("event:/stage-up")

	FmodServer.set_global_parameter_by_name("Phase", stage)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if disable_hit:
			return

		if event.button_index != 1 or not event.is_pressed():
			return
		
		if not can_hit:
			Game.reset_multiplier("miss")
			paws.update_ball_info(BallInfo.random())
		else:
			var ok = paws.hit()

			if not ok:
				Game.reset_multiplier("out of bounds")
				Game.add_points(-500, "out of bounds")
			else:
				Game.add_multiplier(0.05, "hit")

func _on_game_over() -> void:
	disable_hit = true
	FmodServer.set_global_parameter_by_name("Phase", 4)
	stop()

func _on_timeout() -> void:
	var inverse: bool = beat % 2 == 0
	
	if beat != 3:
		if beat == 2:
			var pre_buffer = func():
				can_hit = true
			get_tree().create_timer(wait_time - buffer_time).timeout.connect(pre_buffer)
			
			var after_buffer = func():
				can_hit = false
			get_tree().create_timer(wait_time + buffer_time).timeout.connect(after_buffer)

		var tween: Tween = get_tree().create_tween()
		var rot = table.rotation_degrees + 45 * (-1 if inverse else 1)
		tween.tween_property(table, "rotation_degrees", rot, tween_duration).set_trans(Tween.TRANS_SPRING)

	Game.beat_changed.emit(beat, wait_time)
	beat += 1

	if beat == 4:
		beat = 0

func _on_music_started() -> void:
	start()

func _on_music_stopped() -> void:
	stop()
