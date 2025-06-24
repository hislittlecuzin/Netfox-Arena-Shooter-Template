extends Button

var ut_id : String
var editor_script : map_editor_ui

# Called when the node enters the scene tree for the first time.
func clicked_button():
	editor_script.set_map_to_load(name, ut_id)
