extends Node
class_name custom_field_asset_push_spawn_point

enum push_spawn_point_id {
	red_zero,
	blue_zero,
	red_one,
	blue_one,
	red_two,
	blue_two,
	red_three,
	blue_three
}

@export var position : Vector3 = Vector3.ZERO
@export var rotation : Vector3 = Vector3.ZERO
@export var team : push_spawn_point_id = push_spawn_point_id.red_zero
