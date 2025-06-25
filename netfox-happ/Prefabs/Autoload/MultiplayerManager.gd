extends Node

var my_steam_id

var currentLobby: int

const steam_app_id := 2478900

#The IDs of all the Steam Workshop items
var steam_workshop_items : Array

var steam_enabled = true
var is_host = true

var lobbyUsernames : Array[String] = []
var lobbyIDs : Array[int] = []
var lobbyTeam : Array[int] = []
var lobbyIsSplitScreen : Array[bool] = []
var lobby_player_is_ready : Array[bool] = []
var lobby_connection_id : Array[int] = []

func _ready() -> void:
	my_steam_id = Steam.getSteamID()
	
	steam_workshop_items = Steam.getSubscribedItems()
	for _workshop_item in steam_workshop_items:
		if Steam.getItemState(_workshop_item) == 8:
			Steam.downloadItem(_workshop_item, true)
	pass

func _process(delta: float) -> void:
	Steam.run_callbacks()

func SteamMatchmaking_OnLobbyCreated(_result: int, _lobby: int):
	pass

func AddLobbyUsername(new_id: int):
	#print( "Adding user : ", str(new_id), " Name: ", Steam.getFriendPersonaName(new_id) )
	if false == lobbyIDs.has( new_id ):
		lobbyIDs.push_back( new_id )
		lobbyUsernames.push_back( Steam.getFriendPersonaName( new_id ) )
		lobbyTeam.push_back( 0 )
		lobbyIsSplitScreen.push_back( false )
		lobby_player_is_ready.push_back( false )
		if new_id == Steam.getSteamID() and multiplayer.is_server():
			lobby_connection_id.push_back( 1 )
		else:
			lobby_connection_id.push_back( -1 )
		
		#add username to the pre-game lobby
		var pregameLobby : pregame_lobby = get_tree().root.get_node("PrimaryScene/Steam pre-game_Lobby")
		pregameLobby.AddNewLobbyUsername( new_id )
	else:
		print( "User already exists...", str(new_id) )
	pass

func RemoveUsername(new_steam_id: int):
	var steam_id_to_remove = lobbyIDs.find(new_steam_id)
	var lobby_connection_to_remove = lobby_connection_id[steam_id_to_remove]
	
	var pregameLobby : pregame_lobby = get_tree().root.get_node("PrimaryScene/Steam pre-game_Lobby")
	for entry in pregameLobby.playerList.get_children():
		if entry.player_id == new_steam_id: #Steam ID
			entry.queue_free()
			break
	
	lobbyUsernames.remove_at(steam_id_to_remove)
	lobbyIDs.remove_at(steam_id_to_remove)
	lobbyTeam.remove_at(steam_id_to_remove)
	lobbyIsSplitScreen.remove_at(steam_id_to_remove)
	lobby_player_is_ready.remove_at(steam_id_to_remove)
	lobby_connection_id.remove_at(steam_id_to_remove)
	multiplayer.multiplayer_peer.disconnect_peer(-1)
	
	pregameLobby.multiplayer_spawner._handle_leave(lobby_connection_to_remove)


@rpc("authority", "call_remote", "reliable")
func verify_lobby_data(_l_teams : Array[int], _l_splitscreen : Array[bool], l_con_id : Array[int]):
	for index in l_con_id.size():
		if index >= l_con_id.size():
			break
		
		lobbyTeam[index] = _l_teams[index]
		lobbyIsSplitScreen[index] = _l_splitscreen[index]
		
	pass


func get_mouse_sensitivity():
	var h_slider = get_node("/root/PrimaryScene/Main Menu/VBoxContainer/Settings Button/Mouse Sensitivity HSlider") as HSlider
	return h_slider.value
