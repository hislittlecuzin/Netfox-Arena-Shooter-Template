extends CharacterBody3D
class_name airsoft_bb

var team = -2
const SPEED : int = 350
var projectile_active = false
var ignored_body = null

func _ready() -> void:
	NetworkTime.on_tick.connect(_tick)
	pass
	#$DespawnTimer.start()

func _spawn_data(position: Vector3, rotation: Vector3, new_body_ignore):
	global_position = position
	global_rotation = rotation
	projectile_active = true
	ignored_body = new_body_ignore

func _tick(delta, _t) -> void:
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity()

	var direction := (transform.basis * Vector3(0, 0, -1)).normalized()
	velocity = direction * SPEED

	move_and_slide()

@rpc("authority", "call_local", "reliable")
func _destructor() -> void:
	NetworkTime.on_tick.disconnect(_tick)
	queue_free()

func _on_despawn_timer_timeout():
	if false == multiplayer.is_server():
		pass
		#return
	_destructor.rpc()

func OnBBCollide(body: Node3D) -> void:
	if false == multiplayer.is_server() or projectile_active == false or body == ignored_body:
		return
	print (" I hit something " + name + " Other : " + body.name)
	if body is network_player_v2:
		if body.my_team != team:
			body.player_hit( team )
			#body.am_hit = true
			print ( "Hit player: " + body.name + " " + str( body.am_hit ) )
	_destructor.rpc()
