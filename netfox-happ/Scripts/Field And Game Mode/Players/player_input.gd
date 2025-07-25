extends Node
class_name PlayerInput

var movement: Vector2 = Vector2.ZERO
var shoot : bool = false
var look_vector : Vector2 = Vector2.ZERO

var localMouseDelta: Vector2 = Vector2.ZERO
var mouse_sensitivity : float = .003

func _ready() -> void:
	NetworkTime.before_tick_loop.connect(_gather)

func _gather():
	#print ( "Owned by : ", str( get_multiplayer_authority() ), " I am: ", str( multiplayer.get_unique_id() ) )
	if false == is_multiplayer_authority():
		localMouseDelta = Vector2.ZERO
		#print("Multiplayer authority : ", str ( get_multiplayer_authority() ))
		return
	
	if $"..".player_1:
		movement.x = Input.get_axis("move_left", "move_right")
		movement.y = Input.get_axis("move_forward", "move_backward")
		shoot = Input.is_action_pressed("shoot")
		look_vector = localMouseDelta
		localMouseDelta = Vector2.ZERO
	else:
		movement.x = Input.get_axis("player_2_move_left", "player_2_move_right")
		movement.y = Input.get_axis("player_2_move_forward", "player_2_move_backward")
		shoot = Input.is_action_pressed("player_2_shoot")
		look_vector = 0.15 * Input.get_vector("player_2_look_left", "player_2_look_right", "player_2_look_up", "player_2_look_down")
	
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		localMouseDelta.x += event.relative.x * SteamManager.get_mouse_sensitivity() # mouse_sensitivity
		localMouseDelta.y += event.relative.y * SteamManager.get_mouse_sensitivity() # mouse_sensitivity
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if $"..".field_manager != null:
		if $"..".field_manager.round_ended:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _destructor():
	NetworkTime.before_tick_loop.disconnect(_gather)
