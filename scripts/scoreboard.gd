extends RichTextLabel
class_name Scoreboard

func _ready() -> void:
	Game.scoreboard_updated.connect(update_scoreboard)
	update_scoreboard(get_scoreboard())

func update_scoreboard(scoreboard: Array) -> void:
	text = ""
	for entry in scoreboard:
		if not entry is Dictionary:
			continue

		var place = scoreboard.find(entry)
		text += "#%d %s: %d\n" % [place + 1, entry["name"], entry["score"]]

static func get_scoreboard() -> Array:
	return SaveSystem.get_var("scoreboard", [])

static func add_to_scoreboard(player_name: String, score: int) -> int:
	var scoreboard: Array = get_scoreboard().duplicate()
	var entry = {"name": player_name, "score": score}
	scoreboard.append(entry)
	scoreboard.sort_custom(func(a, b): return a["score"] > b["score"])
	SaveSystem.set_var("scoreboard", scoreboard)
	Game.scoreboard_updated.emit(scoreboard)
	return scoreboard.find(entry) + 1
