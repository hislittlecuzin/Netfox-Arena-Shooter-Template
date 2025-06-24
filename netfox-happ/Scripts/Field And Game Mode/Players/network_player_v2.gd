extends CharacterBody3D
class_name network_player_v2

@export var speed = 0
@export var max_speed = 8.0
var gravity = ProjectSettings.get_setting(&"physics/3d/default_gravity")
@export var input: PlayerInput
var player_id: int = -1
var player_1 : bool = true

var field_manager : FieldManager

# Game Rule Variables
var am_hit : bool = false
var my_team : int = -1

@export var cam : Camera3D
@export var bb : PackedScene
@export var muzzle_device : Node3D

var shot_last_frame = false

@export_category("Models")
@export_category("Third Person")
@export var third_person_body : third_person_render_layer_manager
@export var third_person_arms : third_person_render_layer_manager
@export var arm_bands : Array[CSGCylinder3D]

@export_category("First Person")
@export var first_person_arms : third_person_render_layer_manager

@export var audioPlayers : Array[AudioStreamPlayer3D] = []
var audioPlayerIndex = 0

func _ready() -> void:
	position = Vector3(0, 4, 0)
	
	if input == null:
		input = $Input
	await get_tree().process_frame
	
	if SteamManager.is_host:
		print ( "Host adding: ", str(player_id) )
	else:
		print ( "Client adding: ", str(player_id) )
	
	set_multiplayer_authority( 1 )
	input.set_multiplayer_authority( player_id )
	$RollbackSynchronizer.process_settings( )
	
	$"Models/ArmsDolly/Test OGA Arms/AnimationPlayer".play("SSR4 Idle")
	$"Models/Camo Character/AnimationPlayer".play("Standing Idle Rifle AK")
	$"Models/ArmsDolly/Camo Character2/AnimationPlayer".play("Standing Idle Rifle AK")
	
	NetworkTime.on_tick.connect(_tick)
	
	if player_id == multiplayer.get_unique_id():
		print("I am local player")
		if SteamManager.lobbyIsSplitScreen[ SteamManager.lobby_connection_id.find( multiplayer.get_unique_id() ) ]:
			if player_1:
				set_local_player_1_pawn()
			else:
				set_local_player_2_pawn()
				pass
		else:
			set_local_player_1_pawn()
	else:
		set_not_local_pawn()

func _set_input_authority():
	print("My authority: ", str(player_id))
	input.set_multiplayer_authority(player_id)
	$RollbackSynchronizer.process_settings()

# main loop
func _rollback_tick(delta, _tick, _is_fresh):
	if field_manager != null and field_manager.round_ended:
		return
	
	if am_hit:
		hit_animation_helper_function()
		return
	
	#region movement
	if false == is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
	
	if input.movement != Vector2.ZERO:
		if speed <= max_speed:
			speed += 1
		
		var startingPoint = transform.origin + transform.basis.z
		var endingPoint = transform.origin - transform.basis.z
		var forward_direction = startingPoint.direction_to(endingPoint)
		var strafe_startingPoint = transform.origin + transform.basis.x
		var strafe_endingPoint = transform.origin - transform.basis.x
		var right_direction = strafe_startingPoint.direction_to(strafe_endingPoint)
		velocity.z = 0
		velocity.x = 0
		if input.movement.y > 0.5:
			velocity += -forward_direction
		elif input.movement.y < -0.5:
			velocity += forward_direction
		if input.movement.x > 0.5:
			velocity += -right_direction
		elif input.movement.x < -0.5:
			velocity += right_direction
		velocity *= speed
	else:
		speed = 0
		velocity.x = 0 #move_toward(velocity.x, 0, speed)
		velocity.z = 0 #move_toward(velocity.z, 0, speed)

	# move_and_slide assumes physics delta
	# multiplying velocity by NetworkTime.physics_factor compensates for it
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor
	#endregion
	
	#region look stuff
	rotation.y = rotation.y - input.look_vector.x
	
	#var turret_rotation : int = $CameraDolly.rotation_degrees.x
	#turret_rotation -= input.look_vector.y
	#turret_rotation = clamp(turret_rotation, -45, 45)
	var turret_rotation = ($CameraDolly.rotation.x - input.look_vector.y) 
	$CameraDolly.rotation.x = turret_rotation
	$CameraDolly.rotation_degrees.x = clamp($CameraDolly.rotation_degrees.x, -45, 45)
	$"Models/ArmsDolly".rotation.x = $CameraDolly.rotation.x
	
	#endregion
	

func _process(delta: float) -> void:
	view_scoreboard()

func _tick(_delta, tick):
	if field_manager != null and field_manager.round_ended:
		return
	
	if am_hit:
		hit_animation_helper_function()
		return
	shoot()

#region scoreboard

@export_category("Score and Timer UI")
@export var scoreboard_ui : Control
@export var game_mode_label : Label
@export var red_score_label : Label
@export var blue_score_label : Label
@export var timer_label : Label

func view_scoreboard():
	if input.is_multiplayer_authority() == false or field_manager == null:
		return
	timer_label.visible = true
	timer_label.text = str( int( field_manager.game_timer ) )
	
	if field_manager == null:
		scoreboard_ui.visible = false
		return
	if field_manager.round_started and field_manager.round_ended == false:
		if Input.is_action_just_pressed("view_scoreboard"):
			print ("Is input authority? : ", input.is_multiplayer_authority(), " Field manager null? ", str(field_manager == null), " Round start? ", str( field_manager.round_started ), " endded?? ", str(field_manager.round_ended) )
			if scoreboard_ui.visible == false:
				red_score_label.text = str(field_manager.red_score)
				blue_score_label.text = str(field_manager.blue_score)
				scoreboard_ui.visible = true
			else:
				scoreboard_ui.visible = false

#endregion

#region shootin' n dyin'

#sub method required for spawning projectiles because 
#clients cannot run _rollback_tick() for your main code for spawning projectiles. 
func shoot():
	if input.shoot:
		if shot_last_frame:
			return
		shot_last_frame = true
		var projectile : airsoft_bb = bb.instantiate() as airsoft_bb
		get_tree().root.add_child( projectile )
		projectile._spawn_data(muzzle_device.global_position, muzzle_device.global_rotation, self)
		#print("Shoot!")
		
		audioPlayerIndex += 1
		if audioPlayerIndex >= audioPlayers.size():
			audioPlayerIndex = 0
		if audioPlayers.size() > 0:
			audioPlayers[audioPlayerIndex].play()
		
	else:
		shot_last_frame = false
	

var times_hit = 0
var hurt_hits = 5
@export var out_and_hurt = false
var played_hurt_anim = false
func player_hit(teamHitBy : int):
	am_hit = true
	field_manager.player_died(self)
	times_hit += 1
	if times_hit > hurt_hits:
		out_and_hurt = true
	pass

func hit_animation_helper_function():
	if out_and_hurt == false:
		$"Models/Camo Character/AnimationPlayer".play("Standing Eliminated")
		$"Models/ArmsDolly/Camo Character2/AnimationPlayer".play("Standing Eliminated")
		$"Models/ArmsDolly/Test OGA Arms/AnimationPlayer".play("APose")
	else:
		if played_hurt_anim == false:
			played_hurt_anim = true
			$"Models/Camo Character/AnimationPlayer".play("Standing Eliminated Hurt")
			$"Models/ArmsDolly/Camo Character2/AnimationPlayer".play("Standing Eliminated Hurt")
			$"Models/ArmsDolly/Test OGA Arms/AnimationPlayer".play("APose")

@rpc("authority", "call_local", "reliable")
func _destructor():
	input._destructor()
	await get_tree().process_frame
	NetworkTime.on_tick.disconnect(_tick)
	queue_free()

#endregion

#region Set Render Layers

func set_not_local_pawn():
	third_person_body.set_not_local_pawn()
	third_person_arms.set_not_local_pawn()
	first_person_arms.visible = false
func set_local_player_1_pawn():
	third_person_body.set_local_pawn_player_2()
	third_person_arms.set_local_pawn_player_2()
	first_person_arms.set_local_pawn_player_1()
func set_local_player_2_pawn():
	third_person_body.set_local_pawn_player_1()
	third_person_arms.set_local_pawn_player_1()
	first_person_arms.set_local_pawn_player_2()

#endregion
