extends Node
class_name custom_field_asset_spawn_point

enum spawn_point_team {
	red = 0,
	blue = 1
}

@export var position : Vector3 = Vector3.ZERO
@export var rotation : Vector3 = Vector3.ZERO
@export var team : spawn_point_team = spawn_point_team.red
