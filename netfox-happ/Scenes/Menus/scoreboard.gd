extends Control
class_name Scoreboard

@export var field_manager : FieldManager

@export_category("Score Labels")
@export var red_score_label : Label
@export var blue_score_label : Label

func _ready() -> void:
	set_multiplayer_authority(1)
	pass


func return_to_lobby():
	if multiplayer.is_server():
		full_lobby_return.rpc()


@rpc("authority", "call_local", "reliable")
func full_lobby_return():
	field_manager.return_to_lobby()
	visible = false
