extends HBoxContainer

@onready var beat_one: TextureRect = $BeatOne
@onready var beat_two: TextureRect = $BeatTwo
@onready var beat_three: TextureRect = $BeatThree

@onready var beat_four: TextureRect = $BeatFour/Beat
@onready var beat_four_ring: TextureRect = $BeatFour/Ring

@export var tween_opacity: float = 0.6
@export var disabled_opacity: float = 0.15

func _ready() -> void:
	Game.beat_changed.connect(_on_beat_changed)

	beat_four_ring.modulate.a = 0.0
	beat_four.modulate.a = disabled_opacity
	beat_one.modulate.a = 1.0
	beat_two.modulate.a = disabled_opacity
	beat_three.modulate.a = disabled_opacity

func _on_beat_changed(beat: int, next_beat: float) -> void:
	match beat:
		0:
			beat_four.modulate.a = disabled_opacity
			beat_one.modulate.a = 1.0
		1:
			beat_two.modulate.a = 1.0
		2:
			beat_three.modulate.a = 1.0

			var ring_tween: Tween = get_tree().create_tween()
			ring_tween.tween_property(beat_four_ring, "modulate:a", 1.0, next_beat - 0.2).set_ease(Tween.EaseType.EASE_IN)
		3:
			beat_one.modulate.a = disabled_opacity
			beat_two.modulate.a = disabled_opacity
			beat_three.modulate.a = disabled_opacity
			beat_four_ring.modulate.a = 0.0
			beat_four.modulate.a = 1.0
