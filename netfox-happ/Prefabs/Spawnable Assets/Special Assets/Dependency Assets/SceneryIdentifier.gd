extends Node3D
class_name Scenery_Identifier

enum SceneryType {
	scenery,
	spawn_point,
	control_zone,
	flag,
	conquest_capture_point,
	push_zone_blocker,
	push_spawn_point
}

# The faux UUID of the item in Unix Time.
# Time.get_unix_time_from_system()
@export var ut_id : String = "" #-1

@export var scenery_type : SceneryType
@export var index : int = -1

@export var spawn_point_option : int = -1

@export var control_zone_option : int = -1

@export var flag_option : int = -1

@export var push_zone_blocker_option : int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
