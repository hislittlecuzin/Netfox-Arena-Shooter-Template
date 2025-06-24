extends Node3D
class_name third_person_render_layer_manager

@export var models : Array[MeshInstance3D]
@export var armbands : Array[CSGCylinder3D]

@export var all_view : bool = true
@export var player_1_view : bool = false
@export var player_2_view : bool = false

func set_not_local_pawn():
	for model in models:
		model.set_layer_mask_value(1, true)
		model.set_layer_mask_value(2, false)
		model.set_layer_mask_value(3, false)
	for cyl in armbands:
		cyl.set_layer_mask_value(1, true)
		cyl.set_layer_mask_value(2, false)
		cyl.set_layer_mask_value(3, false)

func set_local_pawn_player_1():
	for model in models:
		model.set_layer_mask_value(1, false)
		model.set_layer_mask_value(2, true)
		model.set_layer_mask_value(3, false)
	for cyl in armbands:
		cyl.set_layer_mask_value(1, false)
		cyl.set_layer_mask_value(2, true)
		cyl.set_layer_mask_value(3, false)

func set_local_pawn_player_2():
	for model in models:
		model.set_layer_mask_value(1, false)
		model.set_layer_mask_value(2, false)
		model.set_layer_mask_value(3, true)
	for cyl in armbands:
		cyl.set_layer_mask_value(1, false)
		cyl.set_layer_mask_value(2, false)
		cyl.set_layer_mask_value(3, true)

#func set_render_layer():
#	for model in models:
#		model.set_layer_mask_value(1, all_view)
#		model.set_layer_mask_value(2, player_1_view)
#		model.set_layer_mask_value(3, player_2_view)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
