extends Control
class_name pregame_lobby_gamemode_select_button

var pregame_lobby : pregame_lobby

var game_mode_this_button : pregame_lobby.game_modes = pregame_lobby.game_modes.airsoft

func setup_button (newGameMode):
	#game_mode_this_button = newGameMode
	$Button.text = newGameMode

#: pregame_lobby.game_modes
func set_game_mode() -> void:
	#print(MPManager.steam_id_to_connection_id_dictionary)
	match($Button.text):
		"airsoft":
			pregame_lobby.set_game_mode(pregame_lobby.game_modes.airsoft)
		"capture_the_flag":
			pregame_lobby.set_game_mode(pregame_lobby.game_modes.capture_the_flag)
		"shamwow":
			pregame_lobby.set_game_mode(pregame_lobby.game_modes.shamwow)
		"conquest":
			pregame_lobby.set_game_mode(pregame_lobby.game_modes.conquest)
		"push":
			pregame_lobby.set_game_mode(pregame_lobby.game_modes.push)
		"lonewolf":
			pregame_lobby.set_game_mode(pregame_lobby.game_modes.lonewolf)
		_:
			pass
	
	#var parsed_value : pregame_lobby.game_modes = pregame_lobby.game_modes.get(game_mode_this_button)
	#pregame_lobby.set_game_mode(parsed_value)#(game_mode_this_button)
