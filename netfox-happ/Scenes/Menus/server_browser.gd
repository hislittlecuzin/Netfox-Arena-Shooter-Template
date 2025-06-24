extends Control
class_name Server_Browser

@export var mainMenu: Main_Menu

func _ready() -> void:
	print ("My username : ", Steam.getPersonaName(), "\n My ID : ", str( Steam.getSteamID() ) )
	Steam.lobby_match_list.connect( SteamMatchmaking_OnLobbyMatchList )
	print("Server browser ready")

func return_to_main_menu():
	mainMenu.visible = true
	visible = false

@export var lobbiesContainer: VBoxContainer
@export var lobbySelector: PackedScene

var lobbyToJoinID: int = 0

func JoinLobby():
	SteamManager.is_host = false
	if lobbyToJoinID != 0:
		Steam.joinLobby(lobbyToJoinID)
	if SteamManager.steam_enabled == false:
		mainMenu.SteamMatchmaking_OnLobbyJoined(0, 0, false, Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS)
		#mainMenu.join()

func lobby_list():
	for btn in $"Panel/ScrollContainer/ServerList VBoxContainer".get_children():
		btn.queue_free()
	print("finding lobbies...")
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	
	Steam.requestLobbyList()
	print("Lobbies requested!")

func SteamMatchmaking_OnLobbyMatchList(these_lobbies: Array) -> void:
	print("Received callback lobby lists")
	for this_lobby in these_lobbies:
		print("Steam lobby: ", str(this_lobby))
		# Pull lobby data from Steam, these are specific to our example
		var lobby_name: String = Steam.getLobbyData(this_lobby, "Info")

		# Get the current number of members
		var lobby_num_members: int = Steam.getNumLobbyMembers(this_lobby)

		# Create a button for the lobby
		var lobby_button = lobbySelector.instantiate()
		lobby_button.selectButton.text = lobby_name + " " + str(lobby_num_members)
		lobby_button.lobbyID = this_lobby
		lobby_button.serverBrowser = self

		# Add the new lobby to the list
		lobbiesContainer.add_child(lobby_button)
	pass
