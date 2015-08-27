extends Spatial

# We use two main songs in this level, which are both stored as streams
var attic_bg
var boss_bg

# The objective of this game is to retrieve a certain number of treasures
export var total_treasures = 0
var treasures_retrieved = 0
export var treasures_to_activate_ghost = 1

# The player can only leave when they have gathered enough treasures
var player_can_leave = false

# Once the player has started leaving, we don't want to let them restart the animation
var game_is_over = false

func _ready():
	# this map uses two songs, and a little narration:
	attic_bg = load("attic/attic.ogg")
	boss_bg = load("attic/boss.ogg")
	
	# start the music!
	get_node("music").set_stream(attic_bg)
	get_node("music").play ()
	change_volume()
	
	# the opening animation makes the player climb the stairs and look around.
	get_node("anim").play("opening")

func _on_goal_body_enter( body ):
	# If the player finishes the level, shut down the ghost and start fading out. When
	# the animation is done, the player is shown the credits
	if body.is_in_group("player") and player_can_leave and not game_is_over:
		get_node("ghost_lady").deactivate()
		get_node("anim").play("closing")
		game_is_over = true
	
	# The player just tossed a treasure down.
	if body.is_in_group ("treasure"):
		body.remove_from_group ("treasure") # Make sure we don't accidentally count this twice
		
		# We keep track of how many treasures have been recovered
		treasures_retrieved += 1
		
		# After a set number, we change music and activate the ghost
		if treasures_retrieved == treasures_to_activate_ghost:
			get_node("music").set_stream(boss_bg)
			get_node("music").play()
			get_node("ghost_lady").activate()
		
		# The player can exit after a sset number of treasures
		if treasures_retrieved >= total_treasures and not player_can_leave:
			get_node("player").show_toast ("You're done! You can leave now.")
			get_node("NoPASS").queue_free()
			player_can_leave = true
		else:
			# Show the player how many treasures are left
			get_node("player").show_toast (str(treasures_retrieved) + "/" + str(total_treasures))

# Set the volume of every stream and sample player to the values in the user configuration
func change_volume():
	var config = get_node("/root/global").config
	
	get_node("music").set_volume(config["music_vol"])
	get_node("Narrator").set_volume(config["voice_vol"])
	get_node("player/snd").set_default_volume(config["sound_vol"])
	get_node("ghost_lady/snd").set_default_volume(config["sound_vol"])