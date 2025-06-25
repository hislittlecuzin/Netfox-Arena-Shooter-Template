extends Node
class_name custom_field_file_definition

@export var field_name : String = ""
@export var ut_id : String = "" # -1 fzt
@export var steam_workshop_id : int = -1

@export var basic_spawns : Dictionary[String, custom_field_asset_spawn_point] = {} #Array[custom_field_asset_spawn_point] = []
#@export var red_spawns : Dictionary[float, custom_field_asset_spawn_point] = {} #Array[custom_field_asset_spawn_point] = []
#@export var blue_spawns : Dictionary[float, custom_field_asset_spawn_point] = {} #Array[custom_field_asset_spawn_point] = []

@export var red_flag : custom_field_asset_flag = null
@export var red_flag_win_zone : custom_field_asset_flag = null
@export var blue_flag : custom_field_asset_flag = null
@export var blue_flag_win_zone : custom_field_asset_flag = null

@export var shamwow_capture_point : custom_field_asset_control_zone = null
@export var conquest_capture_points : Dictionary[String, custom_field_asset_control_zone] = {} #Array[custom_field_asset_conquest_capture_point] = []

@export var push_zone_blockers : Dictionary[String, custom_field_asset_push_zone_blocker] = {} #Array[custom_field_asset_push_zone_blocker] = []
@export var push_spawn_point : Dictionary[String, custom_field_asset_push_spawn_point] = {} # Array[custom_field_asset_push_spawn_point] = []

@export var scenery : Dictionary[String, custom_field_asset_scenery] # Array[custom_field_asset_scenery] = []
