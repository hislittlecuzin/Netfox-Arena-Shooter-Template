extends Control

@export var selectButton : Button

var lobbyID : int

#the server browser script
var serverBrowser : Server_Browser

func SetLobbyToJoin():
	serverBrowser.lobbyToJoinID = lobbyID
