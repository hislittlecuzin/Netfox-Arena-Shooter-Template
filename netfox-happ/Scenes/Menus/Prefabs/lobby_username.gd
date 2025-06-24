extends HBoxContainer
class_name lobby_username_entry

@onready var usernameLabel = $username
@onready var teamSelect : OptionButton = $teamSelect
@onready var splitscreenTick : CheckBox = $"Splitscreen CheckBox"

var username: String
var player_id
var connecting = true

var pre_game_lobby : pregame_lobby # to access the MP Manager and have it set team and stuff

func _ready():
	set_multiplayer_authority(1)
	if multiplayer.is_server():
		usernameLabel.text = username + " connecting..."
	else:
		usernameLabel.text = username
	


@rpc("any_peer", "call_local", "reliable")
func _player_connection_set(connection_id: int):
	if connection_id != multiplayer.multiplayer_peer.get_peer_id_from_steam64(player_id):
		return
	usernameLabel.text = username
	set_multiplayer_authority(connection_id)
	connecting = false
	pass

func splitscreen_check_box_toggled(toggled_on: bool) -> void:
	if is_multiplayer_authority():
		print("Tick box toggled")
		#pre_game_lobby. #tell pregame lobby to update self
		relay_new_local_changes.rpc(teamSelect.selected, splitscreenTick.button_pressed)


func team_select_item_selected(index: int) -> void:
	if is_multiplayer_authority():
		print("Team drop selected")
		#tell pregame lobby to update self
		relay_new_local_changes.rpc(teamSelect.selected, splitscreenTick.button_pressed)


@rpc("authority", "call_local", "reliable")
func relay_new_local_changes(team : int, splitscreen : bool):
	var sender_id = multiplayer.get_remote_sender_id()
	var conn_index = SteamManager.lobby_connection_id.find( sender_id )
	print("Sender: ", str(sender_id) , " Conn Index: ", str(conn_index))
	
	SteamManager.lobbyTeam[conn_index] = team
	SteamManager.lobbyIsSplitScreen[conn_index] = splitscreen
	
	teamSelect.selected = team
	splitscreenTick.button_pressed = splitscreen
	
	#if MPManager.Facepunch.wasHost:
		#var my_index = MPManager.lobbyIDs.find(MPManager.my_steam_id)
		#MPManager.lobbyIsSplitScreen[my_index] = splitscreenTick.button_pressed
		#MPManager.lobbyTeam[my_index] = teamSelect.selected
		#for peer in SyncManager.peers:
			#SyncManager.network_adaptor.send_lobby_player_choices(peer, my_profile_changes)
	#else:
		##client message host
		#print("Host: " + str(MPManager.Facepunch.GetLobbyHostSteamID()))
		#SyncManager.network_adaptor.send_lobby_player_choices(MPManager.Facepunch.GetLobbyHostSteamID(), my_profile_changes)
	pass
