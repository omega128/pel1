extends Spatial

# We use two main songs in this level
var attic_bg
var boss_bg

# The objective of this game is to retrieve a total number of treasures
export var total_treasures = 0
export var treasures_to_activate_ghost = 1
var treasures_retrieved = 0

var fighting_boss = false
var player_can_leave = false

func _ready():
	var config = get_node("/root/global").config

	# this map uses two songs, and a little narration:
	attic_bg = load("attic/attic.ogg")
	boss_bg = load("attic/boss.ogg")
	
	# start the music!
	get_node("music").set_stream(attic_bg)	
	get_node("music").play ()
	get_node("music").set_volume(config["music_vol"])
	
	# the opening animation makes the player look around as they enter the attic.
	get_node("anim").play("opening")

func _on_goal_body_enter( body ):
	if body.is_in_group("player") and player_can_leave:
		get_node("ghost_lady").deactivate()
		get_node("anim").play("closing")
		
	if body.is_in_group ("treasure"):
		body.remove_from_group ("treasure")
		treasures_retrieved += 1
		
		if not fighting_boss and treasures_retrieved == treasures_to_activate_ghost:
			get_node("music").set_stream(boss_bg)
			get_node("music").play()
			get_node("ghost_lady").activate()
			fighting_boss = true
		
		if treasures_retrieved >= total_treasures and not player_can_leave:
			get_node("player").show_toast ("You're done! You can leave now.")
			get_node("NoPASS").queue_free()
			player_can_leave = true
		else:
			get_node("player").show_toast (str(treasures_retrieved) + "/" + str(total_treasures))