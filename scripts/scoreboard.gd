extends TextureRect
class_name Scoreboard

@onready var scoreboard_entry_scene: PackedScene = preload("res://ui/scoreboard_entry.tscn")
@onready var scoreboard_container: VBoxContainer = $ScrollContainer/VBoxContainer

static var local_place: Dictionary = {}

func _ready() -> void:
	Game.scoreboard_updated.connect(update_scoreboard)
	Game.game_started.connect(game_started)
	update_scoreboard(get_scoreboard())

func game_started() -> void:
	local_place = {}

func update_scoreboard(scoreboard: Array) -> void:
	for child in scoreboard_container.get_children():
		child.queue_free()

	var clone = scoreboard.duplicate()
	for index in clone.size():
		var entry: Dictionary = clone[index]
		if not entry is Dictionary:
			continue

		var scoreboard_entry: ScoreboardEntry = scoreboard_entry_scene.instantiate()
		scoreboard_container.add_child(scoreboard_entry)
		entry["local"] = entry == local_place
		scoreboard_entry.set_info(entry)

static func get_scoreboard() -> Array:
	return SaveSystem.get_var("scoreboard", [])

static func add_to_scoreboard(player_name: String, score: int) -> int:
	var scoreboard: Array = get_scoreboard().duplicate()
	local_place = {"name": player_name, "score": score}
	scoreboard.append(local_place)
	scoreboard.sort_custom(func(a, b): return a["score"] > b["score"])

	for index in scoreboard.size():
		scoreboard[index]["position"] = index + 1

	SaveSystem.set_var("scoreboard", scoreboard)
	Game.scoreboard_updated.emit(scoreboard)
	return scoreboard.find(local_place) + 1