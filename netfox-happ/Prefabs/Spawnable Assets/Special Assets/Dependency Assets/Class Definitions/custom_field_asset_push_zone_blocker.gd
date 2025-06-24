extends Node
class_name custom_field_asset_push_zone_blocker

enum push_zone_blocker_zone {
	zero,
	one,
	two,
	three
}

@export var position : Vector3
@export var rotation : Vector3
@export var scale : Vector3

@export var blocker_zone : push_zone_blocker_zone
