extends Control
class_name Main_Menu

@export var server_browser : Server_Browser
@export var pre_game_lobby : pregame_lobby

@export var spawner : Player_Spawner

@export var mpSpawner : Player_Spawner_v3

func _ready() -> void:
	Steam.lobby_created.connect(SteamMatchmaking_OnLobbyCreated)
	Steam.lobby_joined.connect(SteamMatchmaking_OnLobbyJoined)
	Steam.lobby_chat_update.connect(SteamMatchmaking_OnLobbyConditionUpdate)
	multiplayer.peer_connected.connect(_connection_joined)
	multiplayer.connected_to_server.connect(I_am_client_and_Joined)
	print("OS Path : " + OS.get_executable_path().get_base_dir())

func HostMultiplayerLobby():
	
	#e net test stuff
	if SteamManager.steam_enabled == false:
		var peer = ENetMultiplayerPeer.new()
		if peer.create_server(1337) != OK:
			print("Failed to listen on port")
		get_tree().get_multiplayer().multiplayer_peer = peer
		await condition(
			func():
				return peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
		)
		
		get_tree().get_multiplayer().server_relay = true
		SteamMatchmaking_OnLobbyJoined(0, 0, false, Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS)
		#NetworkTime.start()
		#_add_player(1)
		return
	
	#Create Lobby
	else:
		print("Steam netcode")
		Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_PUBLIC, 250)

		var peer = SteamMultiplayerPeer.new()
		var error := peer.create_host(1337)
		if error != OK:
			print("failed to create Steam socket (code %d)" % error)
			return false

		get_tree().get_multiplayer().multiplayer_peer = peer

		await condition(
			func():
				return peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
		)
		get_tree().get_multiplayer().server_relay = true
		#spawner._spawn( Steam.getSteamID() )
		#NetworkTime.start()
		print ("Started net time")
		#_add_player(1)
		return
	#Create Server
	
	#Switch UI to lobby
	
	#MAYBE start network syncer. 
	

func FindLobbies():
	server_browser.visible = true
	visible = false
	server_browser.lobby_list()

func join(_server_id: int):
	
	if SteamManager.steam_enabled:
		var peer = SteamMultiplayerPeer.new()
		var err = peer.create_client(_server_id, 1337) #change first arg to lobby host
		if err != OK:
			print("Failed to create client")
		
		get_tree().get_multiplayer().multiplayer_peer = peer
	
		await condition(
			func():
				return peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
		)
	
		if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
			OS.alert("Failed to connect to %s:%s" % [_server_id, 1337])
			return
	else:
		var peer = ENetMultiplayerPeer.new()
		var err = peer.create_client("localhost", 1337)
		if err != OK:
			OS.alert("Failed to create client, reason: %s" % error_string(err))
			return err

		get_tree().get_multiplayer().multiplayer_peer = peer
	
	# Wait for connection process to conclude
		await condition(
			func():
				return peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
		)

		if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
			#OS.alert("Failed to connect to %s:%s" % [address, port])
			return
	print("Client started")
	#spawner._handle_connected( Steam.getSteamID() )
	#NetworkTime.start()

#save for enet multiplayer testing stuff
func condition(cond: Callable, timeout: float = 10.0) -> Error:
	timeout = Time.get_ticks_msec() + timeout * 1000
	while not cond.call():
		await get_tree().process_frame
		if Time.get_ticks_msec() > timeout:
			return ERR_TIMEOUT
	return OK

#when YOU create the LOBBY
func SteamMatchmaking_OnLobbyCreated(_result: int, _lobby: int):
	Steam.setLobbyJoinable(_lobby, true)
	Steam.setLobbyType(_lobby, $VBoxContainer/HBoxContainer/OptionButton.selected)
	Steam.setLobbyGameServer(Steam.current_steam_id)
	Steam.setLobbyData( _lobby, "Info", Steam.getPersonaName() )
	pass

#when YOU join a lobby
func SteamMatchmaking_OnLobbyJoined(_lobby: int, _permissions: int, _locked: bool, response: int):
	print("I joined lobby ", str(_lobby) )
	if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		#full, failed, banned, etc
		return
	if SteamManager.steam_enabled:
		SteamManager.currentLobby = _lobby
	
	if Steam.getLobbyOwner(_lobby) == Steam.getSteamID() or SteamManager.is_host:
		print("I am host")
		#_add_player(1)
		#NetworkTime.start()
	else:
		print("I am not host")
		await join( Steam.getLobbyOwner( _lobby ) )
		
	if SteamManager.steam_enabled:
		var lobby_count = Steam.getNumLobbyMembers(_lobby)
		for user_index in lobby_count:
			var current_user = Steam.getLobbyMemberByIndex(_lobby, user_index)
			SteamManager.AddLobbyUsername(current_user)
	
	visible = false
	server_browser.visible = false
	pre_game_lobby.visible = true
	if multiplayer.is_server():
		var playerEntries = pre_game_lobby.playerList.get_children()
		for entry : lobby_username_entry in playerEntries:
			if entry.player_id == Steam.getSteamID():
				entry._player_connection_set(1)
			pass

#When someone ELSE joins or disconnects
func SteamMatchmaking_OnLobbyConditionUpdate(_lobby: int, change_id: int, making_change_id: int, chat_state: int):
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		SteamManager.AddLobbyUsername(change_id)
		#SteamManager.lobbyIDs.push_back(change_id)
		#SteamManager.lobbyUsernames.push_back( Steam.getFriendPersonaName(change_id) )
		#SteamManager.lobbyTeam.push_back(0)
		#SteamManager.lobbyIsSplitScreen.push_back(false)
		print ("User joined : ", Steam.getFriendPersonaName(change_id), " ID: ", str(change_id) )
		#spawner._spawn(change_id)
		pass # someone join lobby
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_DISCONNECTED:
		SteamManager.RemoveUsername(change_id)
		#also check if host left; if so, change host. 
		pass #somone dc
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
		SteamManager.RemoveUsername(change_id)
		#also check if host left; if so, change host. 
		pass
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_KICKED:
		SteamManager.RemoveUsername(change_id)
		#also check if host left; if so, change host. 
		pass
	pass

#someone CONNECTED to server (not lobby)
func _connection_joined(connection_id: int):
	print("Am I Host: ", str (SteamManager.is_host), " player connected: ", str(connection_id))
	var steam_id = multiplayer.multiplayer_peer.get_steam64_from_peer_id( connection_id )
	var lobby_index = SteamManager.lobbyIDs.find(steam_id)
	SteamManager.lobby_connection_id[ lobby_index ] = connection_id
	var PGL_Players = pre_game_lobby.playerList.get_children()
	for player : lobby_username_entry in PGL_Players:
		player._player_connection_set.rpc(connection_id)
		pass

func I_am_client_and_Joined():
	pass
	#NetworkTime.start()



#region Map Editor Stuff

@export_category("Map Editor Stuff")
@export_file("*.tscn") var map_editor_scene : String

var map_editor_instance : Node3D

func load_into_map_editor():
	map_editor_instance = load( map_editor_scene ).instantiate()
	map_editor_instance.get_child(0).main_menu_script = self
	get_tree().root.add_child(map_editor_instance)
	visible = false
	pass

func exit_map_editor():
	map_editor_instance.queue_free()
	map_editor_instance = null
	visible = true
	pass

#endregion
