extends Control
class_name map_editor_ui


var main_menu_script : Main_Menu

# ut_id and mapname
var maps_available_to_load : Dictionary = {}
const map_index_file_location : String = "custom_maps/maps.index"
const map_file_save_folder : String = "custom_maps/"

var map_file_to_load_on_load : String = ""
var map_ut_id_to_load_on_load : String = ""
var map_ut_id_to_load_on_save : String = ""

#region export variables

@export var current_field : custom_field_file_definition
@export var navigation_region : Node3D

@export_category("Left Side Menus")
@export_group("Load")
@export var loadAreaMenu : Control
@export var stage_map_to_load_button_template : PackedScene
@export var map_options_to_load_vbox : VBoxContainer

@export_group("Spawn")
@export var spawnAssetsMenu : Control
@export var stage_asset_to_load_button_template : PackedScene
@export var asset_options_to_load_vbox : VBoxContainer

@export_group("Misc")
@export var helpPanel : Panel
@export var selected_object : Scenery_Identifier

#region Asset Spawn Panel

@export_category("Asset Spawn Panel")
@export var assetOptions : Array[PackedScene]

@export var asset_spawn_panel : Panel
var asset_to_spawn : String
var what_to_spawn_index : int = -1
@export var asset_to_spawn_label : Label

@export var list_of_spawnable_assets_v_box : VBoxContainer

#endregion

#region Field Save / Load Panel

@export_category("Save / Load Shared Data")

#var field_files_names_index : Array[String]
#var JSON_MANAGER : JSON = JSON.new()

@export_category("Field Load Panel")
@export var field_load_panel : Panel
@export var field_to_load_lable : Label
#var field_to_load_ut_id : float

@export var list_of_loadable_fields_v_box : VBoxContainer

@export_category("Field Save Panel")
@export var save_panel_line_edit : LineEdit

#endregion

#region Spawn Special Objects

@export_category("Special Object Spawn Control")

@export_group("Spawn Points")
#@export var spawnPoint_Red : PackedScene
@export var spawnPoint_specialObject : PackedScene
@export var special_object_spawnpoint_optionButton : OptionButton

@export_group("Control Zones")
@export var control_zone : PackedScene
@export var special_object_controlzone_optionButton : OptionButton

@export_group("Flag Items")
@export var flag_items : PackedScene
@export var special_object_flagoption_optionButton : OptionButton

@export_group("Conquest")
@export var conquest_flag : PackedScene

@export_group("Push")
@export var push_blocker : PackedScene
@export var special_object_pushblocker_optionButton : OptionButton

@export var push_spawn_point : PackedScene
@export var special_object_pushspawn_optionButton : OptionButton

#endregion

#region Inspector stuff
@export_category("Inspector")
@export var inspectorAssetNameField : LineEdit

@export_group("Position Spin Boxes")
@export var inspectorPositionControl : Control
@export var inspector_X_positionControl : SpinBox
@export var inspector_Y_positionControl : SpinBox
@export var inspector_Z_positionControl : SpinBox

@export_group("Rotation Spin Boxes")
@export var inspectorRotationControl : Control
@export var inspector_X_rotationControl : SpinBox
@export var inspector_Y_rotationControl : SpinBox
@export var inspector_Z_rotationControl : SpinBox

@export_group("Scale Spin Boxes")
@export var inspectorScaleControl : Control
@export var inspector_X_scaleControl : SpinBox
@export var inspector_Y_scaleControl : SpinBox
@export var inspector_Z_scaleControl : SpinBox

@export_group("General Spawn Point Control")
@export var inspectorSpawnPointControl : Control
@export var inspectorSpawnPointOption : OptionButton

@export_group("Control Zone Control")
@export var inspectorControlZoneControl : Control
@export var inspectorControlZoneOption : OptionButton

@export_group("Flag Control")
@export var inspectorFlagControl : Control
@export var inspectorFlagOption : OptionButton

@export_group("Conquest Capture Point Control")
@export var inspectorConquestCapturePointControl : Control
#@export #no control at this time.

@export_group("Push Zone Blocker Control")
@export var inspectorPushZoneBlockerControl : Control
@export var inspectorPushZoneBlockerOption : OptionButton

@export_group("Push Spawn Point Control")
@export var inspectorPushSpawnControl : Control
@export var inspectorPushSpawnOption : OptionButton

#endregion

#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_map()
	print(JSON.stringify(maps_available_to_load)  )
	var map_index_json_file := FileAccess.open(map_index_file_location, FileAccess.READ)
	#maps_available_to_load = JsonClassConverter.json_file_to_dict(map_index_json_file.get_line())
	maps_available_to_load = JSON.parse_string( map_index_json_file.get_line() )
	map_index_json_file.close()
	
	for map_option_key in maps_available_to_load.keys():
		var new_button = stage_map_to_load_button_template.instantiate()
		new_button.name = maps_available_to_load[map_option_key]
		new_button.ut_id = map_option_key
		new_button.text = new_button.name
		new_button.editor_script = self
		map_options_to_load_vbox.add_child(new_button)
	
	#asset thingy
	for asset_option_key in assetOptions.size():
		var new_button = stage_asset_to_load_button_template.instantiate()
		var temp = assetOptions[asset_option_key].instantiate()
		new_button.name = temp.name
		new_button.text = new_button.name
		new_button.index_id = asset_option_key
		new_button.editor_script = self
		#new_button.index = assetOptions.find(asset_option_key)
		#new_button.ut_id = map_option_key
		temp.queue_free()
		asset_options_to_load_vbox.add_child(new_button)
	
	steamworks_callbacks_setup()
	
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#region Main Editor Function

#region Save / Load Functionality

func new_map():
	deselect_scenery()
	current_field = null
	for child in navigation_region.get_children():
		child.queue_free()
	current_field = custom_field_file_definition.new()
	current_field.ut_id = "a" + str( Time.get_unix_time_from_system() )
	map_ut_id_to_load_on_save = current_field.ut_id
	steam_workshop_item_id = -1
	current_field.steam_workshop_id = steam_workshop_item_id
	steam_workshop_item_id_text_input_spin_box.value = -1
	pass

func save_map():
	current_field.field_name = save_panel_line_edit.text
	
	current_field.ut_id = map_ut_id_to_load_on_save
	current_field.steam_workshop_id = steam_workshop_item_id
	var name = maps_available_to_load.get_or_add(current_field.ut_id, current_field.field_name)
	if name != current_field.field_name:
		var new_id_to_use : String = "a" + str( Time.get_unix_time_from_system() )
		maps_available_to_load.get_or_add(new_id_to_use, current_field.field_name)
		map_ut_id_to_load_on_save = new_id_to_use
		current_field.ut_id = new_id_to_use
	var save_map_index = JSON.stringify(maps_available_to_load)
	
	var map_name_hyphenated : String = current_field.ut_id + "-" + current_field.field_name
	DirAccess.make_dir_recursive_absolute("custom_maps/" + map_name_hyphenated)
	var map_file_name : String = "custom_maps/" + map_name_hyphenated + "/" + map_name_hyphenated + ".happmap"
	
	#region generate map file contents
	var _field_to_be : custom_field_file_definition = custom_field_file_definition.new()
	_field_to_be.field_name = current_field.field_name
	_field_to_be.ut_id = current_field.ut_id
	_field_to_be.steam_workshop_id = current_field.steam_workshop_id
	
	for child in navigation_region.get_children():
		if (child is Scenery_Identifier) == false:
			print ("NOT SCENERY??? ", child.name)
			continue
		var dict_id = child.ut_id
		match (child.scenery_type):
			Scenery_Identifier.SceneryType.scenery:
				var scenery_item : custom_field_asset_scenery = custom_field_asset_scenery.new()
				scenery_item.position = child.global_position
				scenery_item.rotation = child.global_rotation_degrees
				scenery_item.scale = child.scale
				scenery_item.scenery_index = child.index
				_field_to_be.scenery.get_or_add(dict_id, scenery_item )
			Scenery_Identifier.SceneryType.spawn_point:
				var scenery_item : custom_field_asset_spawn_point = custom_field_asset_spawn_point.new()
				scenery_item.position = child.global_position
				scenery_item.rotation = child.global_rotation_degrees
				scenery_item.team = child.spawn_point_option
				_field_to_be.basic_spawns.get_or_add(dict_id, scenery_item )
			Scenery_Identifier.SceneryType.control_zone:
				var scenery_item : custom_field_asset_control_zone = custom_field_asset_control_zone.new()
				scenery_item.position = child.global_position
				scenery_item.rotation = child.global_rotation_degrees
				scenery_item.control_zone = child.control_zone_option
				if scenery_item.control_zone == custom_field_asset_control_zone.control_zone_type.shamwow:
					_field_to_be.shamwow_capture_point = scenery_item
				else:
					_field_to_be.conquest_capture_points.get_or_add(dict_id, scenery_item )
			Scenery_Identifier.SceneryType.flag:
				var scenery_item : custom_field_asset_flag = custom_field_asset_flag.new()
				scenery_item.position = child.global_position
				scenery_item.rotation = child.global_rotation_degrees
				scenery_item.flag_purpose = child.flag_option
				if scenery_item.flag_purpose == 0:
					_field_to_be.red_flag = scenery_item
				if scenery_item.flag_purpose == 1:
					_field_to_be.red_flag_win_zone = scenery_item
				if scenery_item.flag_purpose == 2:
					_field_to_be.blue_flag = scenery_item
				if scenery_item.flag_purpose == 3:
					_field_to_be.blue_flag_win_zone = scenery_item
			Scenery_Identifier.SceneryType.conquest_capture_point:
				#Not implemented I think
				pass
			Scenery_Identifier.SceneryType.push_zone_blocker:
				var scenery_item : custom_field_asset_push_zone_blocker = custom_field_asset_push_zone_blocker.new()
				scenery_item.position = child.global_position
				scenery_item.rotation = child.global_rotation_degrees
				scenery_item.scale = child.scale
				scenery_item.blocker_zone = child.push_zone_blocker_option
				_field_to_be.push_zone_blockers.get_or_add(dict_id, scenery_item )
			Scenery_Identifier.SceneryType.push_spawn_point:
				var scenery_item : custom_field_asset_push_spawn_point = custom_field_asset_push_spawn_point.new()
				scenery_item.position = child.global_position
				scenery_item.rotation = child.global_rotation_degrees
				scenery_item.team = child.spawn_point_option
				_field_to_be.push_spawn_point.get_or_add(dict_id, scenery_item )
			_:
				print ("WHAT THE FUCKER? ", child.name)
				pass
		
		pass
	
	#endregion
	
	var save_map_file_access = FileAccess.open(map_file_name , FileAccess.WRITE )
	var save_data = JsonClassConverter.class_to_json_string(_field_to_be)
	save_map_file_access.store_string(save_data)
	save_map_file_access.close()
	
	var save_map_index_file_access = FileAccess.open(map_index_file_location , FileAccess.WRITE )
	save_map_index_file_access.store_string(save_map_index)
	save_map_index_file_access.close()
	
	pass

func load_map():
	if map_file_to_load_on_load == "":
		return
	
	new_map()
	#map_file_save_folder
	
	var hyphenated_map_file : String = map_ut_id_to_load_on_load + "-" + map_file_to_load_on_load
	var _file_name = map_file_save_folder + "/" + hyphenated_map_file + "/" + hyphenated_map_file + ".happmap"
	map_ut_id_to_load_on_save = map_ut_id_to_load_on_load
	var map_to_load_json_file := FileAccess.open(_file_name, FileAccess.READ)
	var map_json_text = map_to_load_json_file.get_as_text()
	current_field = JsonClassConverter.json_string_to_class(custom_field_file_definition , map_json_text)
	#current_field = new_current_field
	map_to_load_json_file.close()
	
	save_panel_line_edit.text = map_file_to_load_on_load
	steam_workshop_item_id = current_field.steam_workshop_id
	steam_workshop_item_id_text_input_spin_box.value = current_field.steam_workshop_id
	#Spawn stuff in.
	#region spawns in objects for the loading of the map.
	
	#red spawns
	for key in current_field.basic_spawns.keys():
		var value = current_field.basic_spawns[key]
		var instance : Scenery_Identifier = spawnPoint_specialObject.instantiate()
		navigation_region.add_child(instance)
		instance.global_position = value.position
		instance.global_rotation_degrees = value.rotation
		instance.spawn_point_option = value.team
		instance.ut_id = key
		if value.team == custom_field_asset_spawn_point.spawn_point_team.red:
			instance.get_child(0).change_shader_red()
		elif value.team == custom_field_asset_spawn_point.spawn_point_team.blue:
			instance.get_child(0).change_shader_blue()
	
	#blue spawns
	#for key in current_field.basic_spawns.keys():
		#var value = current_field.basic_spawns[key]
		#var instance : Scenery_Identifier = spawnPoint_specialObject.instantiate()
		#navigation_region.add_child(instance)
		#instance.global_position = value.position
		#instance.global_rotation = value.rotation
		#instance.spawn_point_option = value.spawn_point_team
		#instance.get_child(0).change_shader_blue()
	
	#red flag
	if current_field.red_flag != null:
		var instance : Scenery_Identifier = flag_items.instantiate()
		navigation_region.add_child(instance)
		instance.global_position = current_field.red_flag.position
		instance.global_rotation_degrees = current_field.red_flag.rotation
		instance.flag_option = current_field.red_flag.flag_purpose
		instance.get_child(0).change_shader_red()
		instance.get_child(0).set_flag()
		
	#red flag win zone
	if current_field.red_flag_win_zone != null:
		var instance : Scenery_Identifier = flag_items.instantiate()
		navigation_region.add_child(instance)
		instance.global_position = current_field.red_flag_win_zone.position
		instance.global_rotation_degrees = current_field.red_flag_win_zone.rotation
		instance.flag_option = current_field.red_flag_win_zone.flag_purpose
		instance.get_child(0).change_shader_red()
		instance.get_child(0).set_win_zone()
	
	#blue flag
	if current_field.blue_flag != null:
		var instance : Scenery_Identifier = flag_items.instantiate()
		navigation_region.add_child(instance)
		instance.global_position = current_field.blue_flag.position
		instance.global_rotation_degrees = current_field.blue_flag.rotation
		instance.flag_option = current_field.blue_flag.flag_purpose
		instance.get_child(0).change_shader_blue()
		instance.get_child(0).set_flag()
		
	#blue flag win zone
	if current_field.blue_flag_win_zone != null:
		var instance : Scenery_Identifier = flag_items.instantiate()
		navigation_region.add_child(instance)
		instance.global_position = current_field.blue_flag_win_zone.position
		instance.global_rotation_degrees = current_field.blue_flag_win_zone.rotation
		instance.flag_option = current_field.blue_flag_win_zone.flag_purpose
		instance.get_child(0).change_shader_blue()
		instance.get_child(0).set_win_zone()
	
	#shamwow
	if current_field.shamwow_capture_point != null:
		var instance : Scenery_Identifier = control_zone.instantiate()
		navigation_region.add_child(instance)
		instance.global_position = current_field.shamwow_capture_point.position
		instance.global_rotation_degrees = current_field.shamwow_capture_point.rotation
		instance.control_zone_option = current_field.shamwow_capture_point.control_zone
		#instance.get_child(0).change_shader_blue()
		#instance.get_child(0).set_win_zone()
	
	# CONQUEST CAPTURE POINTS! NOT YET IMPLEMENTED
	#for key in current_field.conquest_capture_points.keys():
	#	var value = current_field.conquest_capture_points[key]
	#	var instance : Scenery_Identifier = spawnPoint_specialObject.instantiate()
	#	navigation_region.add_child(instance)
	#	instance.global_position = value.position
	#	instance.global_rotation = value.rotation
	#	instance.spawn_point_option = value.spawn_point_team
	#	instance.get_child(0).change_shader_blue()
	
	#push zone blockers
	for key in current_field.push_zone_blockers.keys():
		var value = current_field.push_zone_blockers[key]
		var instance : Scenery_Identifier = push_blocker.instantiate()
		navigation_region.add_child(instance)
		instance.global_position = value.position
		instance.global_rotation_degrees = value.rotation
		instance.ut_id = key
		instance.push_zone_blocker_option = value.blocker_zone
	
	#push spawns
	for key in current_field.push_spawn_point.keys():
		var value = current_field.push_spawn_point[key]
		var instance : Scenery_Identifier = push_spawn_point.instantiate()
		navigation_region.add_child(instance)
		instance.global_position = value.position
		instance.global_rotation_degrees = value.rotation
		instance.ut_id = key
		instance.push_zone_blocker_option = value.team
		if instance.spawn_point_option == 0 or instance.spawn_point_option == 2 or instance.spawn_point_option == 4 or instance.spawn_point_option == 6:
			instance.get_child(0).change_shader_red()
		elif instance.spawn_point_option == 1 or instance.spawn_point_option == 3 or instance.spawn_point_option == 5 or instance.spawn_point_option == 7:
			instance.get_child(0).change_shader_blue()
	
	#scenery
	for key in current_field.scenery.keys():
		var value = current_field.scenery[key]
		#var instance : Scenery_Identifier = load( assetOptions[value.scenery_index] ).instantiate()
		var instance : Scenery_Identifier = assetOptions[value.scenery_index].instantiate()
		navigation_region.add_child(instance)
		instance.global_position = value.position
		instance.global_rotation_degrees = value.rotation
		instance.scale = value.scale
		instance.ut_id = key
	
	#endregion

#endregion

#region show/hide panels

#region change left panel
func Switch_To_Asset_list_button() -> void:
	field_load_panel.visible = false
	asset_spawn_panel.visible = true

func Switch_To_Load_Field_button() -> void:
	field_load_panel.visible = true
	asset_spawn_panel.visible = false
	pass # Replace with function body.
#endregion

#region steamworks panels
func show_workshop_panel():
	steamworks_panel.visible = true

func hide_workshop_panel():
	steamworks_panel.visible = false
#endregion

#region help panel

func show_help_panel():
	helpPanel.visible = true

func hide_help_panel():
	helpPanel.visible = false

#endregion

func quit_to_main_menu():
	main_menu_script.exit_map_editor()

#endregion

#region spawn Special Objects

func SpawnAssetScenery():
	var instance : Scenery_Identifier = assetOptions[what_to_spawn_index].instantiate()
	navigation_region.add_child(instance)
	instance.global_position = Vector3.ZERO
	instance.scale = Vector3.ONE
	
	instance.ut_id = "a" + str( Time.get_unix_time_from_system() )
	
	select_scenery(instance)
	pass

func SpawnSpawnPoint():
	var instance : Scenery_Identifier = spawnPoint_specialObject.instantiate()
	navigation_region.add_child(instance)
	instance.global_position = Vector3.ZERO
	instance.spawn_point_option = special_object_spawnpoint_optionButton.selected
	
	instance.ut_id = "a" + str( Time.get_unix_time_from_system() )
	if special_object_spawnpoint_optionButton.selected == 0:
		instance.get_child(0).change_shader_red()
	elif special_object_spawnpoint_optionButton.selected == 1:
		instance.get_child(0).change_shader_blue()
	
	select_scenery(instance)

func SpawnControlZone():
	var instance : Scenery_Identifier = control_zone.instantiate()
	navigation_region.add_child(instance)
	instance.global_position = Vector3.ZERO
	instance.control_zone_option = special_object_controlzone_optionButton.selected
	
	instance.ut_id = "a" + str( Time.get_unix_time_from_system() )
	
	select_scenery(instance)

func SpawnFlag():
	var instance : Scenery_Identifier = flag_items.instantiate()
	navigation_region.add_child(instance)
	instance.global_position = Vector3.ZERO
	instance.flag_option = special_object_flagoption_optionButton.selected
	
	print("Selected Flag : ", str(instance.flag_option) )
	
	instance.ut_id = "a" + str( Time.get_unix_time_from_system() )
	if instance.flag_option == 0: #flag - red
		instance.get_child(0).change_shader_red()
		instance.get_child(0).set_flag()
	if instance.flag_option == 1: #flag win - red
		instance.get_child(0).change_shader_red()
		instance.get_child(0).set_win_zone()
	if instance.flag_option == 2: #flag - blue
		instance.get_child(0).change_shader_blue()
		instance.get_child(0).set_flag()
	if instance.flag_option == 3: #flag win - blue
		instance.get_child(0).change_shader_blue()
		instance.get_child(0).set_win_zone()
	
	select_scenery(instance)

func SpawnPushBlocker():
	var instance : Scenery_Identifier = push_blocker.instantiate()
	navigation_region.add_child(instance)
	instance.global_position = Vector3.ZERO
	instance.push_zone_blocker_option = special_object_pushblocker_optionButton.selected
	
	instance.ut_id = "a" + str( Time.get_unix_time_from_system() )
	
	select_scenery(instance)

func SpawnPushSpawn():
	var instance : Scenery_Identifier = push_spawn_point.instantiate()
	navigation_region.add_child(instance)
	instance.global_position = Vector3.ZERO
	instance.spawn_point_option = special_object_pushspawn_optionButton.selected
	
	instance.ut_id = "a" + str( Time.get_unix_time_from_system() )
	
	select_scenery(instance)

func SpawnCharacterStartLocation() -> void:
	pass
	#SceneryIdentifier spawnedItem = SetCharacterStartLocation.Instantiate<SceneryIdentifier>();

	# //#spawnedItem.GlobalPosition = areaController.scenerySpawnPoint.GlobalPosition;

	#navigationRegion.AddChild(spawnedItem);

	#spawnedItem.GlobalPosition = new Vector3(
	#	(float)((int)(areaController.scenerySpawnPoint.GlobalPosition.X)),
	#	(float)((int)(areaController.scenerySpawnPoint.GlobalPosition.Y)),
	#	(float)((int)(areaController.scenerySpawnPoint.GlobalPosition.Z))
	#	);

	#spawnedItem.id = Guid.NewGuid();
	#GD.Print("New GUID: " + spawnedItem.id);

	#SelectScenery(spawnedItem);
	#setCharacterStartLocations.Add(spawnedItem);

#endregion

#region select / deselect / delete

func deselect_scenery():
	#if selected_object == null:
		#return
	
	inspectorPositionControl.visible = false
	inspectorRotationControl.visible = false
	inspectorScaleControl.visible = false
	inspectorSpawnPointControl.visible = false
	inspectorControlZoneControl.visible = false
	inspectorFlagControl.visible = false
	inspectorConquestCapturePointControl.visible = false
	inspectorPushZoneBlockerControl.visible = false
	inspectorPushSpawnControl.visible = false
	
	selected_object = null

func delete():
	if selected_object == null:
		return
	
	match(selected_object.scenery_type):
		Scenery_Identifier.SceneryType.spawn_point:
			current_field.basic_spawns.erase(selected_object.ut_id)
			pass
		Scenery_Identifier.SceneryType.control_zone:
			if selected_object.control_zone_option == 0:
				current_field.shamwow_capture_point = null
			else: # selected_object.control_zone_option == 1
				current_field.conquest_capture_points.erase(selected_object.ut_id)
		Scenery_Identifier.SceneryType.flag:
			if selected_object.flag_option == 0:
				current_field.red_flag = null
			elif selected_object.flag_option == 1:
				current_field.red_flag_win_zone = null
			elif selected_object.flag_option == 2:
				current_field.blue_flag = null
			elif selected_object.flag_option == 3:
				current_field.blue_flag_win_zone = null
		Scenery_Identifier.SceneryType.conquest_capture_point:
			current_field.conquest_capture_points.erase(selected_object.ut_id)
		Scenery_Identifier.SceneryType.push_zone_blocker:
			current_field.push_zone_blockers.erase(selected_object.ut_id)
		Scenery_Identifier.SceneryType.push_spawn_point:
			current_field.push_spawn_point.erase(selected_object.ut_id)
		_:
			pass
	selected_object.queue_free()
	selected_object = null
	deselect_scenery()

func select_scenery(selectedProp : Scenery_Identifier):
	deselect_scenery()
	
	inspector_X_positionControl.value = selectedProp.global_position.x
	inspector_Y_positionControl.value = selectedProp.global_position.y
	inspector_Z_positionControl.value = selectedProp.global_position.z
	
	inspector_X_rotationControl.value = selectedProp.global_rotation_degrees.x
	inspector_Y_rotationControl.value = selectedProp.global_rotation_degrees.y
	inspector_Z_rotationControl.value = selectedProp.global_rotation_degrees.z
	
	#Find object in the 
	print ("UISelected ", selectedProp.name)
	
	inspectorPositionControl.visible = true
	inspectorRotationControl.visible = true
	
	inspectorAssetNameField.text = selectedProp.name
	
	match (selectedProp.scenery_type):
		Scenery_Identifier.SceneryType.scenery:
			inspector_X_scaleControl.value = selectedProp.scale.x
			inspector_Y_scaleControl.value = selectedProp.scale.y
			inspector_Z_scaleControl.value = selectedProp.scale.z
			
			inspectorScaleControl.visible = true
		Scenery_Identifier.SceneryType.spawn_point:
			
			#.selected = selected_object.spawn_point_option
			
			inspectorSpawnPointControl.visible = true
		Scenery_Identifier.SceneryType.control_zone:
			inspectorControlZoneOption.selected = selectedProp.control_zone_option
			
			inspector_X_scaleControl.value = selectedProp.scale.x
			inspector_Y_scaleControl.value = selectedProp.scale.y
			inspector_Z_scaleControl.value = selectedProp.scale.z
			
			inspectorControlZoneControl.visible = true
			inspectorScaleControl.visible = true
		Scenery_Identifier.SceneryType.flag:
			inspectorFlagOption.selected = selectedProp.flag_option
			
			inspectorFlagControl.visible = true
		Scenery_Identifier.SceneryType.conquest_capture_point:
			#no options for conquest capture point control
			
			inspectorConquestCapturePointControl.visible = true
		Scenery_Identifier.SceneryType.push_zone_blocker:
			inspectorPushZoneBlockerOption.selected = selectedProp.push_zone_blocker_option
			
			inspector_X_scaleControl.value = selectedProp.scale.x
			inspector_Y_scaleControl.value = selectedProp.scale.y
			inspector_Z_scaleControl.value = selectedProp.scale.z
			
			inspectorScaleControl.visible = true
			inspectorPushZoneBlockerControl.visible = true
		Scenery_Identifier.SceneryType.push_spawn_point:
			inspectorPushSpawnOption.selected = selectedProp.spawn_point_option
			inspectorPushSpawnControl.visible = true
		_:
			pass
	selected_object = selectedProp

# Time.get_unix_time_from_system()
func quick_spawn(spawnPos : Vector3):
	pass

#endregion


#region Inspector Adjustements Edited

func position_adjusted(foo : float):
	if selected_object == null:
		return
	selected_object.global_position = Vector3(inspector_X_positionControl.value, inspector_Y_positionControl.value, inspector_Z_positionControl.value)

func rotation_adjusted(foo : float):
	if selected_object == null:
		return
	selected_object.global_rotation_degrees = Vector3(inspector_X_rotationControl.value, inspector_Y_rotationControl.value, inspector_Z_rotationControl.value)

func scale_adjusted(foo : float):
	if selected_object == null:
		return
	selected_object.scale = Vector3(inspector_X_scaleControl.value, inspector_Y_scaleControl.value, inspector_Z_scaleControl.value)

func spawn_point_adjusted(foo : int):
	if selected_object == null:
		return
	#basic spawn
	if selected_object.scenery_type == selected_object.SceneryType.spawn_point:
		selected_object.spawn_point_option = inspectorSpawnPointOption.selected
		if foo == 0:
			selected_object.get_child(0).change_shader_red()
		elif foo == 1:
			selected_object.get_child(0).change_shader_blue()
	#push spawn
	elif selected_object.scenery_type == selected_object.SceneryType.push_spawn_point:
		selected_object.spawn_point_option = inspectorPushSpawnOption.selected
		if foo == 0 or foo == 2 or foo == 4 or foo == 6:
			selected_object.get_child(0).change_shader_red()
		elif foo == 1 or foo == 3 or foo == 5 or foo == 7:
			selected_object.get_child(0).change_shader_blue()

func control_zone_adjusted(foo : int):
	if selected_object == null:
		return
	selected_object.control_zone_option = inspectorControlZoneOption.selected

func flag_adjusted(foo : int):
	if selected_object == null:
		return
	selected_object.flag_option = inspectorFlagOption.selected

func conquest_capture_point_adjusted():
	if selected_object == null:
		return
	print("No changes available")
	#selected_object.control_zone_option = 
	pass

func push_zone_adjusted(foo : int):
	if selected_object == null:
		return
	selected_object.push_zone_blocker_option = inspectorPushZoneBlockerOption.selected

#endregion


func set_map_to_load(new_name : String, new_ut_id : String):
	print("Load Area Button")
	map_file_to_load_on_load = new_name
	map_ut_id_to_load_on_load = new_ut_id
	field_to_load_lable.text = map_file_to_load_on_load + "\n" + map_ut_id_to_load_on_load
	#hoveringName.Text = argument

func set_scenery_to_load(name_to_load : String, index_to_spawn : int):
	print("Spawnable Scenery Button")
	what_to_spawn_index = index_to_spawn
	asset_to_spawn_label.text = name_to_load + "\n" + str(index_to_spawn)
	#print("Index: " + whatToSpawnIndex + " ")

#endregion


#region Steamworks Workshop Code:

@export_category("Steam Workshop")
@export var steamworks_panel : Panel
@export var steamworks_map_to_upload_label : Label
@export var steamworks_item_description_text_edit : TextEdit

@export var steamworks_warn_accept_tos_label : Label
@export var steamworks_create_button : Button
@export var steamworks_update_button : Button

@export var steam_workshop_item_id : int = -1
#@export var steam_workshop_item_id_text_input_line_edit : LineEdit
@export var steam_workshop_item_id_text_input_spin_box : SpinBox

#all the callbacks for the calls being made
func steamworks_callbacks_setup():
	Steam.item_created.connect(on_create_new_steamworks_item_success_callback)
	Steam.item_updated.connect(on_item_updated_steamworks_item_callback)
	pass

#region create Steamworks item
#calls to create item
func create_new_steamworks_item():
	Steam.createItem(SteamManager.steam_app_id, Steam.WorkshopFileType.WORKSHOP_FILE_TYPE_COMMUNITY)
	
	pass
#confirms item creation
func on_create_new_steamworks_item_success_callback(result_enum : int, file_id : int, accepted_tos_of_workshop : bool):
	if accepted_tos_of_workshop == true:
		#steamworks_create_button.disabled = true
		#steamworks_update_button.disabled = true
		steamworks_warn_accept_tos_label.text = "Accept TOS before uploading."
		Steam.activateGameOverlayToWebPage("steam://url/CommunityFilePage/" + str(file_id), 0 )
		return
	if result_enum != Steam.RESULT_OK:
		#steamworks_create_button.disabled = true
		#steamworks_update_button.disabled = true
		steamworks_warn_accept_tos_label.text = "Error Code : " + str(result_enum)
	steam_workshop_item_id = file_id
	steamworks_warn_accept_tos_label.text = "Item ID Received : " + str(steam_workshop_item_id)
	#steam_workshop_item_id_text_input_line_edit.text = str(steam_workshop_item_id)
	steam_workshop_item_id_text_input_spin_box.value = steam_workshop_item_id
	pass

#endregion

#region edit Steamworks item

#func steam_workshop_item_id_line_edit_text_changed(new_text : String):
	#if new_text
	#pass

func update_existing_steamworks_item():
	steamworks_warn_accept_tos_label.text = "Updating..."
	if steam_workshop_item_id_text_input_spin_box.value < 0:
		steamworks_warn_accept_tos_label.text = "Add an appropriate Steam Workshop ID."
		return
	
	var update_handle : int = Steam.startItemUpdate(SteamManager.steam_app_id, int( steam_workshop_item_id_text_input_spin_box.value ) ) # ID of Steam Workshop Item
	
	if false == Steam.setItemTitle(update_handle, current_field.field_name):
		steamworks_warn_accept_tos_label.text = "Failed to update Title!"
		return
	if false == Steam.setItemDescription(update_handle, steamworks_item_description_text_edit.text):
		steamworks_warn_accept_tos_label.text = "Failed to update Description!"
		return
	var file_path : String = OS.get_executable_path().get_base_dir() + "/custom_maps/" + current_field.ut_id + "-" + current_field.field_name
	print(file_path)
	if false == Steam.setItemContent(update_handle, file_path):
		steamworks_warn_accept_tos_label.text = "Failed to set item Content!"
		return
	
	Steam.submitItemUpdate(update_handle, "foobar") # Change note is the string.
	pass


func on_item_updated_steamworks_item_callback(result: int, need_accept_tos: bool):
	if need_accept_tos:
		steamworks_warn_accept_tos_label.text = "Accept TOS before updating existing mods."
	match (result):
		1:
			steamworks_warn_accept_tos_label.text = "Uploaded successfully!"
		_:
			steamworks_warn_accept_tos_label.text = "Error code : " + str(result)
	pass

#endregion

#endregion
