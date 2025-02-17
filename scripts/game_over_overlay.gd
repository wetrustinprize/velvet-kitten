extends Panel
class_name GameOverOverlay

var listen_keyboard: bool = false
var listen_player_name: bool = true
var player_name_input: String = ""

@onready var highscore_guide: Label = $TextureRect/HighscoreGuide
@onready var good_game: Label = $TextureRect/WinContainer/GoodGame
@onready var player_name: Label = $TextureRect/HighscoreContainer/PlayerName

func set_score(score: int) -> void:
	good_game.text = "Good game! You made %d points!" % score

func fade_in() -> void:
	modulate.a = 0
	visible = true

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.1)

	get_tree().create_timer(0.1).timeout.connect(func():
		listen_keyboard = true
	)

func _input(event: InputEvent) -> void:
	if not listen_keyboard:
		return

	if event is InputEventKey:
		if event.is_echo():
			return

		if event.keycode == KEY_ESCAPE:
			Game.restart_game()

		if not listen_player_name:
			return

		if event.is_released():
			return

		if event.keycode == KEY_BACKSPACE:
			player_name_input = player_name_input.substr(0, player_name_input.length() - 1)
		elif event.keycode == KEY_ENTER:
			if player_name_input.length() < 3:
				return

			listen_player_name = false

			var place = Scoreboard.add_to_scoreboard(player_name_input, Game.score)
			highscore_guide.text = "Thanks for playing! You are in #%d place!" % (place + 1)

			var player_name_tween = create_tween()
			player_name_tween.tween_property(player_name, "modulate:a", 0.5, 0.05)
			player_name_tween.tween_interval(1)
			player_name_tween.tween_property(player_name, "modulate:a", 1, 0.05)
			player_name_tween.tween_interval(1)
			player_name_tween.set_loops(0)
			return
		elif event.keycode:
			if event.as_text().length() == 1:
				if player_name_input.length() < 3:
					player_name_input += event.as_text()

		var remaining_length = 3 - player_name_input.length()
		player_name.text = player_name_input + " _".repeat(remaining_length)