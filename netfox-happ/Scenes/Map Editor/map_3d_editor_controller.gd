extends CharacterBody3D


const SPEED = 10.0
@export var mouse_sensitivity : float = 0.003

var looking = false

@export var cam : Camera3D
@export var area_editor : map_editor_ui

var start_click : Vector2 = Vector2.ZERO
var raycast_to : Vector3 = Vector3.ZERO
var raycast_length : float = 200.0

var clicking : bool = false
var right_clicking : bool = false

func _physics_process(delta: float) -> void:
	movement_code()
	
	select_item()

#toggle_look_mode
func movement_code():
	
	var Velocity : Vector3  = velocity
	var inputDir : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var upDownMove : float = Input.get_axis("move_up", "move_down")

	var direction : Vector3 = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	direction.y = upDownMove
	if (direction != Vector3.ZERO):
		Velocity.x = direction.x * SPEED
		Velocity.y = direction.y * SPEED
		Velocity.z = direction.z * SPEED
	else:
		Velocity.x = move_toward(Velocity.x, 0, SPEED)
		Velocity.y = move_toward(Velocity.y, 0, SPEED)
		Velocity.z = move_toward(Velocity.z, 0, SPEED)

	velocity = Velocity
	move_and_slide()

func select_item():
	if (looking == false):
		if (clicking == true):
			clicking = false
			var worldSpace : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
			var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(cam.global_position, raycast_to, 5)
			var result = worldSpace.intersect_ray(query)
			if (result.is_empty() == false): #(result["count"] > 0):
				if result["collider"] is Scenery_Identifier:
					var selectedProp : Scenery_Identifier = result["collider"] as Scenery_Identifier
					print("Selected: " + selectedProp.name)
					area_editor.select_scenery(selectedProp)
	elif (looking == true):
		if (right_clicking == true):
			right_clicking = false
			var worldSpace : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
			var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(cam.global_position, raycast_to, 2)
			var result = worldSpace.intersect_ray(query)
			if result.is_empty() == false:#(result["count"] > 0):
				var spawnPos : Vector3 = result["position"] as Vector3 #.As<Vector3>()
				print("Spawn Position: " + str(spawnPos) )
				area_editor.quick_spawn(spawnPos)

func _unhandled_input(event: InputEvent) -> void:
	match (looking):
		true:
			if event is InputEventMouseButton:# as eventMouseButtonLooking:
				if (event.button_index == 2 && event.pressed == true):
					right_clicking = true
					raycast_to = cam.project_ray_origin(event.position) + cam.project_ray_normal(event.position) * raycast_length
		false:
			if event is InputEventMouseButton:# as eventMouseButton:
				if (event.pressed == true):
					if (event.button_index == 1):
						clicking = true
					if event.button_index == 2 and looking:
						right_clicking = true
					start_click = event.position
					raycast_to = cam.project_ray_origin(event.position) + cam.project_ray_normal(event.position) * raycast_length


func _input(inputEvent : InputEvent):

	if (inputEvent.is_action_pressed("toggle_look_mode")):
		if (looking == true):
			Input.mouse_mode = Input.MouseMode.MOUSE_MODE_VISIBLE
			looking = false
		elif (looking == false):
			Input.mouse_mode = Input.MouseMode.MOUSE_MODE_CAPTURED
			looking = true
	if (looking == true):
		if (inputEvent is InputEventMouseMotion):
			rotate_object_local(Vector3.DOWN, inputEvent.relative.x * mouse_sensitivity)
			cam.rotate_object_local(Vector3.LEFT, inputEvent.relative.y * mouse_sensitivity)
			if (cam.rotation.x > 1.8):
				print("Look up")
				cam.rotate_object_local(Vector3.RIGHT, inputEvent.relative.y * mouse_sensitivity)
			elif (cam.rotation.x < -1.8):
				print("Look down")
				cam.rotate_object_local(Vector3.RIGHT, inputEvent.relative.y * mouse_sensitivity)
