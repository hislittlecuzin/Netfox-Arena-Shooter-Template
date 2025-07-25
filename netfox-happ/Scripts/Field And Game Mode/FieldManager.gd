extends Node3D
class_name FieldManager

@export var playerPawns : Array[network_player_v2]

var red_spawn_point_index = 0
@export var red_spawns : Array[Marker3D]
var blue_spawn_point_index = 0
@export var blue_spawns : Array[Marker3D]

@onready var spectator_cam = $Camera3D
var player_1_camera : Camera3D
var player_2_camera : Camera3D

var multiplayer_spawner : Player_Spawner_v3
var splitscreen_manager : split_screen_cameras
var scoreboard : Scoreboard
var pre_game_lobby : pregame_lobby

var round_started : bool = false
var round_ended : bool = false
var current_game_mode : pregame_lobby.game_modes = pregame_lobby.game_modes.airsoft
@export var red_score = 0
@export var blue_score = 0
@export var score_to_win = 15
@export var red_arm_band_material : StandardMaterial3D = preload("res://Prefabs/red_arm_band.tres")
@export var blue_arm_band_material : StandardMaterial3D = preload("res://Prefabs/blue_arm_band.tres")

@export var game_timer : float = 0
const airsoft_time_limit = 300

enum e_dead_splitscreen{
	singleplayer,
	player_1,
	player_2
}

var dead_players : Array[network_player_v2] = []
var dead_player_timers : Array[float] = []
var dead_connections : Array[int] = []
var dead_split_screen : Array[e_dead_splitscreen] = []

var respawning_connections : Array[int]
var respawning_timers : Array[float] = []
var default_respawn_time : float = 5.0
var respawning_split_screen : Array[e_dead_splitscreen] = []

func _ready() -> void:
	if multiplayer.is_server():
		NetworkTime.on_tick.connect(_tick)
	pass

func _tick(delta, _t):
	if round_ended or not round_started:
		return
	
	game_timer -= delta
	if game_timer <= 0:
		game_over.rpc()
	
	for _timer_index in dead_player_timers.size():
		if _timer_index >= dead_player_timers.size():
			break
		#dead_player_timers[_timer_index] -= delta
		if dead_player_timers[_timer_index] <= NetworkTime.local_time:
			respawning_connections.append( dead_connections[_timer_index] )
			respawning_timers.append( NetworkTime.local_time + default_respawn_time )
			respawning_split_screen.append( dead_split_screen[_timer_index] )
			
			dead_player_timers.remove_at( _timer_index )
			dead_players[_timer_index]._destructor.rpc()
			dead_players.remove_at( _timer_index )
			dead_connections.remove_at( _timer_index )
			dead_split_screen.remove_at( _timer_index )
	for _respawn_index in respawning_timers.size():
		
		#prevent overflow
		if _respawn_index >= respawning_timers.size():
			break
		
		#print(" Respawn timer value ", str(respawning_timers[_respawn_index]), " ID ", str( respawning_connections[_respawn_index] ), " Local time ", str(NetworkTime.local_time) )
		if respawning_timers[_respawn_index] < NetworkTime.local_time:
			#start respawn process
			var resp_steamID = multiplayer.multiplayer_peer.get_steam64_from_peer_id( respawning_connections[_respawn_index] )
			var resp_playerIndex = SteamManager.lobbyIDs.find( resp_steamID )
			var resp_team = SteamManager.lobbyTeam[ resp_playerIndex ] # set spawn at right place...
			if respawning_split_screen[ _respawn_index ] == e_dead_splitscreen.player_2:
				resp_team = SteamManager.lobbySplitscreenTeam[ resp_playerIndex ]
			
			if resp_team == pregame_lobby.teams.red:
				#temporatily allow respawning at all times. 
				#region respawn splitscreen
				match respawning_split_screen[ _respawn_index ]:
					e_dead_splitscreen.player_1:
						posssess_pawn.rpc( respawning_connections[ _respawn_index ], true )
					e_dead_splitscreen.player_2:
						posssess_pawn.rpc( respawning_connections[ _respawn_index ], false )
					_:
						posssess_pawn.rpc( respawning_connections[ _respawn_index ] )
				#endregion
				respawning_connections.remove_at( _respawn_index )
				respawning_timers.remove_at( _respawn_index )
				respawning_split_screen.remove_at( _respawn_index )
				match ( current_game_mode ):
					pregame_lobby.game_modes.airsoft:
						pass
					_:
						pass
			else:
				#region respawn splitscreen
				match respawning_split_screen[ _respawn_index ]:
					e_dead_splitscreen.player_1:
						posssess_pawn.rpc( respawning_connections[ _respawn_index ], true )
					e_dead_splitscreen.player_2:
						posssess_pawn.rpc( respawning_connections[ _respawn_index ], false )
					_:
						posssess_pawn.rpc( respawning_connections[ _respawn_index ] )
				#endregion
				respawning_connections.remove_at( _respawn_index )
				respawning_timers.remove_at( _respawn_index )
				respawning_split_screen.remove_at( _respawn_index )
		#check can this player respawn based on team & game mode
		
		
		#posssess_pawn( dead_player, SteamManager.lobbyIsSplitScreen[ playerIndex ] )
		pass
	pass

# Called when the node enters the scene tree for the first time.
func FAUX_ready():
	if false == multiplayer.is_server():
		return
	
	await ( get_tree().create_timer(3.0).timeout )
	
	print("Showing peers: ")
	
	var pawn_data = {}
	#pawn_data["player_count"] = SyncManager.peers.size() + 1
	
	var currentPawn : int = 0
	#posssess_pawn(currentPawn, MPManager.my_steam_id)
	#pawn_data[currentPawn] = MPManager.my_steam_id
	#currentPawn += 1
	
	
	print("Assigning pawn Peer IDs:")
	for peer_id in SteamManager.lobbyIDs:#SyncManager.peers:
		#if peer_id == MPManager.my_steam_id:
			#continue
		#get_tree().get_multiplayer().multiplayer_peer.
		pawn_data[currentPawn] = peer_id
		pawn_data[str(currentPawn) + " player_1"] = true
		var playerIndex = SteamManager.lobbyIDs.find(peer_id) #MPManager.lobbyIDs.find(MPManager.my_steam_id, 0)
		#currentPawn = posssess_pawn(currentPawn, peer_id, false)#MPManager.lobbyIsSplitScreen[playerIndex])
		#print("Peer p1: " + str(peer_id) + " Pawn Index : " + str(currentPawn) + " Split Screen? " + str(MPManager.lobbyIsSplitScreen[playerIndex]))
		#posssess_pawn(currentPawn, peer_id, true) # Figure out if player 1 or player two is true or false!
		if SteamManager.lobbyIsSplitScreen[playerIndex]:
			currentPawn += 1
			#Call possess pawn AGAIN but for player 2!
			#print("Peer p2: " + str(peer_id) + " Pawn Index : " + str(currentPawn) + " Split Screen? " + str(MPManager.lobbyIsSplitScreen[playerIndex]))
			#posssess_pawn(currentPawn, peer_id, false) #"Is player 1 = false"
			pawn_data[currentPawn] = peer_id
			pawn_data[str(currentPawn) + " player_1"] = false
			pawn_data["player_count"] += 1
		currentPawn += 1
		
		#playerPawns[currentPawn].set_multiplayer_authority(peer_id)
	
	#while currentPawn < playerPawns.size():
		# do some shit to hide IG mofo. 
		
		
		#currentPawn += 1
	
	#for peer_id in SyncManager.peers:
		#SyncManager.network_adaptor.assign_client_multiplayer_authority(peer_id, pawn_data)
	#var playerIndex = MPManager.lobbyIDs.find(MPManager.my_steam_id, 0)
	#if MPManager.lobbyIsSplitScreen[playerIndex]:
		#setup split screen camera modes. 
		pass
	
	await ( get_tree().create_timer(3.0).timeout )
	#SyncManager.start()
	Input.MouseMode.MOUSE_MODE_CAPTURED

@rpc("authority", "call_local", "reliable")
func posssess_pawn(connection_id: int, player_1: bool = true):
	print( "Peer ID: " + str(connection_id) )
	
	#print("Peer Authority : " + str(playerPawns[pawn_index].id_of_network_authority) )
	#possess player 1
	
	var current_pawn : network_player_v2 = multiplayer_spawner._spawn(connection_id)
	
	current_pawn.player_id = connection_id
	current_pawn.player_1 = player_1
	current_pawn._set_input_authority()
	current_pawn.field_manager = self
	
	#region split screen team check
	if current_pawn.player_1 == true:
		current_pawn.my_team = SteamManager.lobbyTeam[ SteamManager.lobby_connection_id.find(connection_id) ]
	else: # Is player 2
		current_pawn.my_team = SteamManager.lobbySplitscreenTeam[ SteamManager.lobby_connection_id.find(connection_id) ]
	#endregion
	
	if connection_id == multiplayer.multiplayer_peer.get_peer_id_from_steam64( Steam.getSteamID() ):
		if false == SteamManager.lobbyIsSplitScreen[ SteamManager.lobby_connection_id.find( connection_id ) ]:
				current_pawn.cam.current = true
		#IS split screen. Activate Splitscreen and have cameras follow. 
		else:
			splitscreen_manager.visible = true
			if player_1:
				splitscreen_manager.player_1_camera_dolly = current_pawn.cam
			else:
				splitscreen_manager.player_2_camera_dolly = current_pawn.cam
	else:
		#not a local pawn. 
		#playerPawns[pawn_index].set_not_local_pawn()
		pass
	
	var index_in_mp_manager = SteamManager.lobby_connection_id.find( connection_id )
	print("Player connection : ", str(connection_id), " Team: ", str(SteamManager.lobbyTeam[index_in_mp_manager]) )
	if current_pawn.my_team == 0: #SteamManager.lobbyTeam[index_in_mp_manager] == 0: #red
		for cyl in current_pawn.arm_bands:
			cyl.material = red_arm_band_material
		current_pawn.global_position = red_spawns[red_spawn_point_index].global_position
		current_pawn.global_rotation = red_spawns[red_spawn_point_index].global_rotation
		red_spawn_point_index += 1
		if red_spawn_point_index >= red_spawns.size():
			red_spawn_point_index = 0
		pass
	else: # blue
		for cyl in current_pawn.arm_bands:
			cyl.material = blue_arm_band_material
		current_pawn.global_position = blue_spawns[blue_spawn_point_index].global_position
		current_pawn.global_rotation = blue_spawns[blue_spawn_point_index].global_rotation
		blue_spawn_point_index += 1
		if blue_spawn_point_index >= blue_spawns.size():
			blue_spawn_point_index = 0
		pass
	
	
	##then also possess a player 2
	#if false:
		#
		#playerPawns[pawn_index].id_of_network_authority = peer_id
		#
		#playerPawns[pawn_index].cam.current = true
		#playerPawns[pawn_index].is_local_authority = true
		#playerPawns[pawn_index].cam.current = true
		#player_2_camera = playerPawns[pawn_index].cam
		##makes player 2 controlled by player 2 controlls
		#playerPawns[pawn_index].player_1 = false
	
	

#region game mode events

@rpc("authority", "call_local", "reliable")
func game_over():
	round_ended = true
	scoreboard.visible = true
	scoreboard.red_score_label.text = str(red_score)
	scoreboard.blue_score_label.text = str(blue_score)

@rpc("authority", "call_local", "reliable")
func return_to_lobby():
	splitscreen_manager.player_1_camera_dolly = null
	splitscreen_manager.player_2_camera_dolly = null
	splitscreen_manager.visible = false
	
	multiplayer_spawner._handle_stop()
	
	pre_game_lobby.visible = true
	Steam.setLobbyJoinable(SteamManager.currentLobby , true)
	
	self.queue_free()
	pass

# player died
# - Airsoft, score
# - Respawn
# - - Respawn modes
# - - Shamwow
# - "Push" prep next fallback 

func player_died(player : network_player_v2):
	#if already dead... don't re-kill.
	if dead_connections.has(player.player_id):
		return
	
	#region splitscreen dead camera observe code
	var _my_steam_index = SteamManager.lobbyIDs.find( Steam.getSteamID() )
	var _my_steam_id = SteamManager.lobby_connection_id[ _my_steam_index ]
	if player.input.get_multiplayer_authority() == _my_steam_id:
		if SteamManager.lobbyIsSplitScreen[ _my_steam_index ]:
			if player.player_1:
				splitscreen_manager.player_1_camera_dolly = spectator_cam
			else:
				splitscreen_manager.player_2_camera_dolly = spectator_cam
	#endregion
	
	match (current_game_mode):
		pregame_lobby.game_modes.airsoft:
			if player.my_team == pregame_lobby.teams.red:
				blue_score += 1
				print("Blue score: ", str(blue_score) )
				if blue_score >= score_to_win:
					game_over()
			else:
				red_score += 1
				print("Red score: ", str(red_score) )
				if red_score >= score_to_win:
					game_over()
			pass
		pregame_lobby.game_modes.shamwow:
			pass
		pregame_lobby.game_modes.push:
			pass
		_:
			pass
	print("Player Died : ", str( player.player_id ) )
	dead_connections.append(player.player_id)
	dead_players.append(player)
	dead_player_timers.append(NetworkTime.local_time + 3.0)
	#region dead parallell array splitscreen
	if SteamManager.lobbyIsSplitScreen[ _my_steam_index ]:
		if player.player_1:
			dead_split_screen.append( e_dead_splitscreen.player_1 )
		else:
			dead_split_screen.append( e_dead_splitscreen.player_2 )
	else:
		dead_split_screen.append( e_dead_splitscreen.singleplayer )
	#endregion
	pass



# flag picked up
# flag captured
# flag returned
# zone contested
# - Shamwow
# conquest conquored
# - point flipped

#endregion



func start_match_round(start_time, _game_mode : pregame_lobby.game_modes, _the_lobby : pregame_lobby):
	if round_started:
		return
	current_game_mode = _game_mode
	game_timer = airsoft_time_limit
	pre_game_lobby = _the_lobby
	round_started = true
	for peer in SteamManager.lobbyIDs:
		print (" SPAWNING Lobby ID : ", str( peer ) )
		var con = multiplayer.multiplayer_peer.get_peer_id_from_steam64(peer)
		
		print( "Possessing pawns here ID : ", str(con) )
		
		#spawn and possess
		posssess_pawn(con, true)
		#if split screen... do it again!
		if SteamManager.lobbyIsSplitScreen[ SteamManager.lobbyIDs.find(peer) ]:
			posssess_pawn(con, false)
			pass
	
	pass
