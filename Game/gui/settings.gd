extends WindowDialog

# The settings dialog can be called from the menu or the game. Either way, we want
# to remember the mouse mode that was in place before we started using it.
var mouse_mode

# Config points to the global singleton hash that stores our user configuration options
var config

func _ready ():
	# Stop anything else that might b erunning, save the mouse mode so we can restore it later, and make sure we can use the mouse
	get_tree().set_pause(true)
	mouse_mode = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# get the system configuration
	config = get_node("/root/global").config
	print (config)
	
	# Set up the...	
	# VIDEO options:
	get_node("tabs/Video/shadows_checkbox").set_pressed(config["show_shadows"])
	get_node("tabs/Video/particles_checkbox").set_pressed(config["show_particles"])

	# SOUND options:
	get_node("tabs/Sound/grid/music_volume_slider").set_value(config["music_vol"])
	get_node("tabs/Sound/grid/sound_volume_slider").set_value(config["sound_vol"])
	get_node("tabs/Sound/grid/voice_volume_slider").set_value(config["voice_vol"])
	get_node("tabs/Sound/grid/subtitles_checkbox").set_pressed(config["show_subtitles"])
	get_parent().change_volume()

func _on_save_button_pressed():
	# Save the ...
	# VIDEO options:
	config["show_shadows"] = get_node("tabs/Video/shadows_checkbox").is_pressed()
	config["show_particles"] = get_node("tabs/Video/particles_checkbox").is_pressed()

	# SOUND options:
	config["show_subtitles"] = get_node("tabs/Sound/grid/subtitles_checkbox").is_pressed()
	config["music_vol"] = get_node("tabs/Sound/grid/music_volume_slider").get_value()
	config["sound_vol"] = get_node("tabs/Sound/grid/sound_volume_slider").get_value()
	config["voice_vol"] = get_node("tabs/Sound/grid/voice_volume_slider").get_value()

	# Save the configuration to disk
	get_node("/root/global").save_config()
	
	# Get rid of this dialog
	_on_settings_hide()
	
# Restore everything, and get rid of this dialog box.
func _on_settings_hide():
	get_parent().change_volume()
	Input.set_mouse_mode(mouse_mode)
	get_tree().set_pause(false)
	self.queue_free()

# the volume volume is the only one (right now) that lets the player "preview" it, by changing the music
# volume as the player changes the slider
func _on_volume_slider_value_changed( value ):
	get_node("../music").set_volume (value)
