extends Node3D


@export var red_spawn_shader : ShaderMaterial
@export var blue_spawn_shader : ShaderMaterial

@export var myShaderMaterial : ShaderMaterial

@export var pole_mesh : MeshInstance3D
@export var flag_mesh : MeshInstance3D

func _ready():
	change_shader_red()
	set_flag()

func change_shader_blue():
	myShaderMaterial = blue_spawn_shader
	pole_mesh.material_override = myShaderMaterial
	flag_mesh.material_override = myShaderMaterial

func change_shader_red():
	myShaderMaterial = red_spawn_shader
	pole_mesh.material_override = myShaderMaterial
	flag_mesh.material_override = myShaderMaterial

func set_flag():
	flag_mesh.visible = true

func set_win_zone():
	flag_mesh.visible = false
