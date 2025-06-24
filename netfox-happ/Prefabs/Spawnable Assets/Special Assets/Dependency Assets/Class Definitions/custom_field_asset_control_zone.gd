extends Node
class_name custom_field_asset_control_zone


enum control_zone_type {
	shamwow,
	zone_a,
	zone_b,
	zone_c
}

@export var position : Vector3
@export var rotation : Vector3
@export var control_zone : control_zone_type
