extends Control

func _ready ():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_node("anim").play("teeter")
	get_node("fade").play("fade_in")
	get_node("music").set_volume (get_node("/root/global").config["music_vol"])

func _on_back_button_pressed():
	get_node("/root/global").goto_scene ("res://gui/menu.scn")
