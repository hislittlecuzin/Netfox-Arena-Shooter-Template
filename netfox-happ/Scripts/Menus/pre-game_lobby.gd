extends Control
class_name pregame_lobby

@onready var playerList : VBoxContainer = $"Player Panel/Player List VBoxContainer"

var playerNames = []

@export_file var default_map = "res://Scenes/Fields/Prototype/empty_field.tscn"
@export_file("*.tscn") var retail_maps : Array[String]
var currently_loaded_map_in_game : FieldManager = null

@export var whatToLoadTemplate: PackedScene# = "res://Scenes/Fields/Prototype/empty_field.tscn"
@onready var mapList: VBoxContainer = $"Map Select/ScrollContainer/Map List"
@export var mapSelectedLabel : Label
var map_selected_index = -1

@export var lobbyUsernameTemplate: PackedScene
@onready var usernameList: VBoxContainer = $"Player Panel/Player List VBoxContainer"

@export var gameModes : PackedScene

#how long it takes to start the game.
@export var time_to_start : float = 5.0

@export var multiplayer_spawner : MultiplayerSpawner
@export var scoreboard : Scoreboard
@export var split_screen_manager : split_screen_cameras

enum game_modes {
	airsoft,
	capture_the_flag,
	shamwow,
	conquest,
	push,
	lonewolf
}

enum teams {
	red,
	blue,
	yellow,
	green,
	violet,
	white,
	black,
	magenta
}

var game_mode_selected : game_modes = game_modes.airsoft

func _ready():
	
	print ( " Red value : ", str(teams.red) )
	set_multiplayer_authority(1)
	#temporary aesthetic
	add_button_to_load_list("Godot Playground", 0)
	add_button_to_load_list("Zulu 24 'New Town'", 1)
	add_button_to_load_list("Ballahack Airsoft 'Highrise'", 2)
	
	#for i in game_modes:
	#	var game_mode_cur_selector : pregame_lobby_gamemode_select_button = gameModes.instantiate()
	#	game_mode_cur_selector.setup_button(i)
	#	game_mode_cur_selector.pregame_lobby = self
	#	$"Game Mode/ScrollContainer/Gamemode List".add_child(game_mode_cur_selector)

#region start game

#Called by "Host Player"
func StartGame():
	#if false == MPManager.STEAM_ENABLED:
		#return
	if false == multiplayer.is_server():
		return
	
	Steam.setLobbyJoinable(SteamManager.currentLobby, false)
	
	SteamManager.verify_lobby_data.rpc(SteamManager.lobbyTeam, SteamManager.lobbyIsSplitScreen, SteamManager.lobby_connection_id)
	
	# Load into game
	client_start_game_retail_map.rpc(map_selected_index, game_mode_selected)

@rpc("authority", "call_local", "reliable")
func client_start_game_retail_map(map: int = -1, _game_mode: game_modes = game_modes.airsoft):
	
	visible = false
	
	load_retail_map(map)
	
	inform_server_am_ready.rpc()
	print("Players in lobby : ", str( SteamManager.lobbyIDs.size() ) )
	if SteamManager.lobbyIDs.size() < 2:
		field_manager_start_match(NetworkTime.time + time_to_start, _game_mode)

func load_retail_map(map: int):
	var inst
	if map < 0 or map >= retail_maps.size():
		inst = load( retail_maps[0] )
	else:
		inst = load( retail_maps[map] )
	currently_loaded_map_in_game = inst.instantiate() as FieldManager #var load_map = inst.instantiate()
	get_tree().root.add_child(currently_loaded_map_in_game) #get_tree().root.add_child(load_map)
	currently_loaded_map_in_game.multiplayer_spawner = multiplayer_spawner
	currently_loaded_map_in_game.scoreboard = scoreboard
	currently_loaded_map_in_game.splitscreen_manager = split_screen_manager
	
	scoreboard.field_manager = currently_loaded_map_in_game
	
	match map:
		-1:
			print("Going to default map")
			#get_tree().instantiate(default_map)
		_:
			print("Going to retail map")
			#get_tree().change_scene_to_file(maps[map])


@rpc("any_peer", "call_local", "reliable")
func inform_server_am_ready():
	if multiplayer.is_server():
		var player_ready = multiplayer.multiplayer_peer.get_steam64_from_peer_id( multiplayer.get_remote_sender_id() )
		SteamManager.lobby_player_is_ready[SteamManager.lobbyIDs.find(player_ready)] = true
		for ready_state in SteamManager.lobby_player_is_ready:
			print ( "Called by : ", str( multiplayer.get_remote_sender_id() ), " ready state ", str( ready_state ),  )
			if ready_state == false:
				return
		#tell players to start. 
		var start_time = NetworkTime.time + time_to_start
		field_manager_start_match.rpc(start_time, game_mode_selected)

@rpc("any_peer", "call_local", "reliable")
func field_manager_start_match(start_time, _game_mode : game_modes):
	currently_loaded_map_in_game.start_match_round(start_time, _game_mode, self)

#endregion

func setup_level_select():
	pass

#region Set level to load - Retail

func add_button_to_load_list(item: String, mapIndex : int = -2):
	var loadSelectButton = whatToLoadTemplate.instantiate() as what_to_load_map_button
	loadSelectButton.name = item
	loadSelectButton.text = item
	loadSelectButton.retail_map_index = mapIndex
	loadSelectButton.editorScript = self
	
	mapList.add_child(loadSelectButton)

func SetMapToLoad(to_load_name : String, retail_map_index : int):
	if retail_map_index == -2:
		print("Custom Maps not yet supported.")
		return
	if retail_map_index < 0:
		print("Error in map index for button setup!!")
		return
	
	if retail_map_index < retail_maps.size():
		mapSelectedLabel.text = to_load_name
		map_selected_index = retail_map_index
	else:
		print("ERROR! Map selected 'index' out of bounds of retail maps! Defaulting to default map.")
		mapSelectedLabel.text = "Godot Playground"
		map_selected_index = -1

#endregion

func SetPregameLobbyUsernames():
	if true:#MPManager.STEAM_ENABLED:
		for index in SteamManager.lobbyUsernames.size():
		#for username in MPManager.lobbyUsernames:
			AddNewLobbyUsername( SteamManager.lobbyIDs[index] ) #AddNewLobbyUsername(username, 0)
			#var label: Label = Label.new()
			#label.text = username
			#playerList.add_child(label)
			#playerNames.push_back(label)

func AddNewLobbyUsername(new_peer_id: int):
	if true:#MPManager.STEAM_ENABLED:
		#print("I AM THE ONE SPAWNING NAMES")
		var newUsername : lobby_username_entry = lobbyUsernameTemplate.instantiate()
		
		#newUsername.set_multiplayer_authority(new_peer_id)
		
		newUsername.username = Steam.getFriendPersonaName( new_peer_id )
		#newUsername.teamSelect
		
		playerList.add_child(newUsername)
		playerNames.push_back(newUsername)
		
		newUsername.player_id = new_peer_id
		
		if SteamManager.my_steam_id == new_peer_id:
			newUsername.teamSelect.disabled = false
			newUsername.splitscreenTick.disabled = false
	pass


#region set game mode

# FINISH SET GAME MODE OR DELETE THIS METHOD FOR THE PREMADE ONES BELOW
func set_game_mode(game_mode_this_button):
	game_mode_selected = game_mode_this_button
	#$"Game Mode/HBoxContainer/Game Mode Selected".text = game_modes.get(game_mode_selected)#game_mode_selected#game_mode_this_button

func set_game_mode_airsoft():
	#print("Peers: ", SyncManager.peers)
	print("Peers MP Manager: ", SteamManager.steam_id_to_connection_id_dictionary)
	if multiplayer.is_server():
		return
	game_mode_selected = game_modes.airsoft
	$"Game Mode/HBoxContainer/Game Mode Selected".text = "Airsoft"
	relay_game_mode.rpc(game_modes.airsoft)
func set_game_mode_capture_the_flag():
	if multiplayer.is_server():
		return
	game_mode_selected = game_modes.capture_the_flag
	$"Game Mode/HBoxContainer/Game Mode Selected".text = "Capture the Flag"
	relay_game_mode.rpc(game_modes.capture_the_flag)
func set_game_mode_shamwow():
	if multiplayer.is_server():
		return
	game_mode_selected = game_modes.shamwow
	$"Game Mode/HBoxContainer/Game Mode Selected".text = "Shamwow"
	relay_game_mode(game_modes.shamwow)
func set_game_mode_conquest():
	if multiplayer.is_server():
		return
	game_mode_selected = game_modes.conquest
	$"Game Mode/HBoxContainer/Game Mode Selected".text = "Conquest"
	relay_game_mode.rpc(game_modes.conquest)
func set_game_mode_push():
	if multiplayer.is_server():
		return
	game_mode_selected = game_modes.push
	$"Game Mode/HBoxContainer/Game Mode Selected".text = "Push"
	relay_game_mode.rpc(game_modes.push)

func client_show_game_mode(game_mode_to_display):
	$"Game Mode/HBoxContainer/Game Mode Selected".text = game_mode_to_display
	pass

@rpc("authority", "call_remote", "reliable")
func relay_game_mode(game_mode_arg : game_modes):
	if multiplayer.is_server():
		return
	#send by message through network
	game_mode_selected = game_mode_arg
	$"Game Mode/HBoxContainer/Game Mode Selected".text = pregame_lobby.game_modes.keys()[game_mode_arg]
	pass

#endregion
