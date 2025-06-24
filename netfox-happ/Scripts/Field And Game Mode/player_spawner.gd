extends Node
class_name Player_Spawner

@export var player_prefab : PackedScene
@export var spawn_root: Node

var avatars: Dictionary = {}

func _ready():
	#return
	NetworkEvents.on_client_start.connect(_handle_connected)
	NetworkEvents.on_server_start.connect(_handle_host)
	NetworkEvents.on_peer_join.connect(_handle_new_peer)
	NetworkEvents.on_peer_leave.connect(_handle_leave)
	NetworkEvents.on_client_stop.connect(_handle_stop)
	NetworkEvents.on_server_stop.connect(_handle_stop)

func _handle_connected(id: int):
	print("Handle connected : ", str(id))
	_spawn(id)

func _handle_host():
	print("Handle host ")
	_spawn( Steam.getSteamID() )

func _handle_new_peer(id: int):
	print("Handle new peer : ", str(id))
	if ( Steam.getLobbyOwner( SteamManager.currentLobby ) == Steam.getSteamID() and id == Steam.getSteamID() ):
		print("I already exist!")
		return
	_spawn(id)

func _handle_leave(id: int):
	print("Handle leave : ", str(id))
	if false == avatars.has(id):
		return
	
	var avatar = avatars[id] as Node
	avatar.queue_free()
	avatars.erase(id)

func _handle_stop():
	for avatar in avatars.values():
		avatar.queue_free()
	avatars.clear()


func _spawn(id: int):
	print("Spawn : ", str(id))
	var avatar = player_prefab.instantiate() as Node
	avatars[id] = avatar
	avatar.name += " #%d" % id
	spawn_root.add_child(avatar)
	
	#authority always server
	#avatar.set_multiplayer_authority( Steam.getLobbyOwner( SteamManager.currentLobby ) )
	avatar.set_multiplayer_authority(1)
	
	print ("Spawned avatar %s at %s" % [avatar.name, multiplayer.get_unique_id()])
	
	
	var input = avatar.find_child("Input")
	if input != null:
		input.set_multiplayer_authority(id)
		print ("Set Inputs(%s) onwership to %s" % [input.name, id])
