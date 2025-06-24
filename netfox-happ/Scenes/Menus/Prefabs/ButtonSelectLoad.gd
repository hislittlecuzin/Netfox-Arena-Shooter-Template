extends Button
class_name what_to_load_map_button

var to_load_name: String
var editorScript : pregame_lobby

var retail_map_index : int = -2


func on_clicked():
	print(to_load_name + text)
	editorScript.SetMapToLoad(text, retail_map_index)#(to_load_name, retail_map_index)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
