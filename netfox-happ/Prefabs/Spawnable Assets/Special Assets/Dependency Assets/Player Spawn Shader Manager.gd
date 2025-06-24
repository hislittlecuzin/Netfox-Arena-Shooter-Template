extends Node3D

@export var red_spawn_shader : ShaderMaterial
@export var blue_spawn_shader : ShaderMaterial

@export var myShaderMaterial : ShaderMaterial

@export var arrow_indicator : CSGMesh3D

func _ready():
	myShaderMaterial = red_spawn_shader
	var head : MeshInstance3D             = get_node("Head")
	var torso : MeshInstance3D            = get_node("Torso")
	var abdomin : MeshInstance3D          = get_node("Abdomin")
	var pelvis : MeshInstance3D           = get_node("Pelvis")
	var LeftThigh : MeshInstance3D        = get_node("Upper Leg_R")
	var RightThigh : MeshInstance3D       = get_node("Upper Leg_L")
	var upperArmLeft : MeshInstance3D     = get_node("Bicep_L")
	var upperArmRight : MeshInstance3D    = get_node("Bicep_R")
	var lowerArmLeft : MeshInstance3D     = get_node("Forearm_R")
	var lowerArmRight : MeshInstance3D    = get_node("Forearm_L")
	var handLeft : MeshInstance3D         = get_node("Hand_R")
	var handRight : MeshInstance3D        = get_node("Hand_L")
	var shinLeft : MeshInstance3D         = get_node("Lower Leg_R")
	var shinRight : MeshInstance3D        = get_node("Lower Leg_L")
	var footLeft : MeshInstance3D         = get_node("Foot_L")
	var footRight : MeshInstance3D        = get_node("Foot_R")

	print("working...");

	head.material_override = myShaderMaterial
	torso.material_override = myShaderMaterial
	abdomin.material_override = myShaderMaterial
	pelvis.material_override = myShaderMaterial
	LeftThigh.material_override = myShaderMaterial
	RightThigh.material_override = myShaderMaterial
	upperArmLeft.material_override = myShaderMaterial
	upperArmRight.material_override = myShaderMaterial
	lowerArmLeft.material_override = myShaderMaterial
	lowerArmRight.material_override = myShaderMaterial
	handLeft.material_override = myShaderMaterial
	handRight.material_override = myShaderMaterial
	shinLeft.material_override = myShaderMaterial
	shinRight.material_override = myShaderMaterial
	footLeft.material_override = myShaderMaterial
	footRight.material_override = myShaderMaterial
	
	arrow_indicator.material_override = myShaderMaterial

func change_shader_blue():
	myShaderMaterial = blue_spawn_shader
	
	var head : MeshInstance3D             = get_node("Head")
	var torso : MeshInstance3D            = get_node("Torso")
	var abdomin : MeshInstance3D          = get_node("Abdomin")
	var pelvis : MeshInstance3D           = get_node("Pelvis")
	var LeftThigh : MeshInstance3D        = get_node("Upper Leg_R")
	var RightThigh : MeshInstance3D       = get_node("Upper Leg_L")
	var upperArmLeft : MeshInstance3D     = get_node("Bicep_L")
	var upperArmRight : MeshInstance3D    = get_node("Bicep_R")
	var lowerArmLeft : MeshInstance3D     = get_node("Forearm_R")
	var lowerArmRight : MeshInstance3D    = get_node("Forearm_L")
	var handLeft : MeshInstance3D         = get_node("Hand_R")
	var handRight : MeshInstance3D        = get_node("Hand_L")
	var shinLeft : MeshInstance3D         = get_node("Lower Leg_R")
	var shinRight : MeshInstance3D        = get_node("Lower Leg_L")
	var footLeft : MeshInstance3D         = get_node("Foot_L")
	var footRight : MeshInstance3D        = get_node("Foot_R")
	
	head.material_override = myShaderMaterial
	torso.material_override = myShaderMaterial
	abdomin.material_override = myShaderMaterial
	pelvis.material_override = myShaderMaterial
	LeftThigh.material_override = myShaderMaterial
	RightThigh.material_override = myShaderMaterial
	upperArmLeft.material_override = myShaderMaterial
	upperArmRight.material_override = myShaderMaterial
	lowerArmLeft.material_override = myShaderMaterial
	lowerArmRight.material_override = myShaderMaterial
	handLeft.material_override = myShaderMaterial
	handRight.material_override = myShaderMaterial
	shinLeft.material_override = myShaderMaterial
	shinRight.material_override = myShaderMaterial
	footLeft.material_override = myShaderMaterial
	footRight.material_override = myShaderMaterial
	
	arrow_indicator.material_override = myShaderMaterial

func change_shader_red():
	myShaderMaterial = red_spawn_shader
	
	var head : MeshInstance3D             = get_node("Head")
	var torso : MeshInstance3D            = get_node("Torso")
	var abdomin : MeshInstance3D          = get_node("Abdomin")
	var pelvis : MeshInstance3D           = get_node("Pelvis")
	var LeftThigh : MeshInstance3D        = get_node("Upper Leg_R")
	var RightThigh : MeshInstance3D       = get_node("Upper Leg_L")
	var upperArmLeft : MeshInstance3D     = get_node("Bicep_L")
	var upperArmRight : MeshInstance3D    = get_node("Bicep_R")
	var lowerArmLeft : MeshInstance3D     = get_node("Forearm_R")
	var lowerArmRight : MeshInstance3D    = get_node("Forearm_L")
	var handLeft : MeshInstance3D         = get_node("Hand_R")
	var handRight : MeshInstance3D        = get_node("Hand_L")
	var shinLeft : MeshInstance3D         = get_node("Lower Leg_R")
	var shinRight : MeshInstance3D        = get_node("Lower Leg_L")
	var footLeft : MeshInstance3D         = get_node("Foot_L")
	var footRight : MeshInstance3D        = get_node("Foot_R")
	
	head.material_override = myShaderMaterial
	torso.material_override = myShaderMaterial
	abdomin.material_override = myShaderMaterial
	pelvis.material_override = myShaderMaterial
	LeftThigh.material_override = myShaderMaterial
	RightThigh.material_override = myShaderMaterial
	upperArmLeft.material_override = myShaderMaterial
	upperArmRight.material_override = myShaderMaterial
	lowerArmLeft.material_override = myShaderMaterial
	lowerArmRight.material_override = myShaderMaterial
	handLeft.material_override = myShaderMaterial
	handRight.material_override = myShaderMaterial
	shinLeft.material_override = myShaderMaterial
	shinRight.material_override = myShaderMaterial
	footLeft.material_override = myShaderMaterial
	footRight.material_override = myShaderMaterial
	
	arrow_indicator.material_override = myShaderMaterial
