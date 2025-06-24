extends Control
class_name split_screen_cameras

@export var field_manager : FieldManager
var is_multiplayer = false
@export var player_1_camera : Camera3D
var player_1_camera_dolly = null
@export var player_2_camera : Camera3D
var player_2_camera_dolly = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup_splitscreen():
	visible = true
	is_multiplayer = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_1_camera_dolly != null and player_2_camera_dolly != null:
		player_1_camera.global_position = player_1_camera_dolly.global_position
		player_1_camera.global_rotation = player_1_camera_dolly.global_rotation
		
		player_2_camera.global_position = player_2_camera_dolly.global_position
		player_2_camera.global_rotation = player_2_camera_dolly.global_rotation
