extends Button

var index_id : int
var editor_script : map_editor_ui

# Called when the node enters the scene tree for the first time.
func clicked_button():
	editor_script.set_scenery_to_load(name, index_id)
