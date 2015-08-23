extends Node

func _ready ():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_node("anim").play("fade_in")
	change_volume()

# This is probably the most straightforward code in the game:
func _on_button_selected( button ):
	if button == 0: # Play
		get_node("/root/global").goto_scene("res://attic/attic.scn")
		
	if button == 1: # Settings
		var settings = load("res://gui/settings.scn").instance()
		get_tree().get_current_scene().add_child(settings)

	if button == 2: # Credits
		get_node("/root/global").goto_scene("res://gui/about.scn")

	if button == 3: # Quit
		get_tree().quit()
		
# Set the volume of the stream player to the values in the user configuration
func change_volume():
	var config = get_node("/root/global").config
	get_node("music").set_volume(config["music_vol"])