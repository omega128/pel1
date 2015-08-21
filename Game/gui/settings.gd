extends WindowDialog

var config

func _ready ():
	config = get_node("/root/global").config
	
	# VIDEO:
	get_node("tabs/Video/shadows_checkbox").set_pressed(config["show_shadows"])
	get_node("tabs/Video/particles_checkbox").set_pressed(config["show_particles"])

	# SOUND:
	get_node("tabs/Sound/grid/music_volume_slider").set_value(config["music_vol"])	
	#get_node("tabs/Sound/grid/sound_volume_slider").set_value(config["sound_vol"])
	#get_node("tabs/Sound/grid/voice_volume_slider").set_value(config["voice_vol"])
	get_node("tabs/Sound/grid/subtitles_checkbox").set_pressed(config["show_subtitles"])

func _on_save_button_pressed():
	# VIDEO:
	config["show_shadows"] = get_node("tabs/Video/shadows_checkbox").is_pressed()
	config["show_particles"] = get_node("tabs/Video/particles_checkbox").is_pressed()
		
	# AUDIO:
	config["music_vol"] = get_node("tabs/Sound/grid/music_volume_slider").get_value()
	get_node("../music").set_volume(config["music_vol"])
	#config["sound_vol"] = get_node("tabs/Sound/grid/sound_volume_slider").get_value()
	#config["voice_vol"] = get_node("tabs/Sound/grid/voice_volume_slider").get_value()
	config["show_subtitles"] = get_node("tabs/Sound/grid/subtitles_checkbox").is_pressed()
	
	# after we save, free this dialog box
	get_tree().set_pause(false)
	self.queue_free()
	
