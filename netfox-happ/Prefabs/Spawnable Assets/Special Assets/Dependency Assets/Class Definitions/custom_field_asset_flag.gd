extends Node
class_name custom_field_asset_flag

enum flag_type {
	red_flag,
	red_win_zone,
	blue_flag,
	blue_win_zone
}

@export var position : Vector3
@export var rotation : Vector3
@export var flag_purpose : flag_type
