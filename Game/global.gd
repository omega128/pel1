extends Node

# this will store system settings
export var config = {}

# We need to track the current scene, so we can easily switch between scenes in-game.
var current_scene = null


func _ready ():
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )
	_set_default_config ()

	
# If any config values are not set, fill them with default values.
func _set_default_config ():	
	var defaults = {
		# VIDEO
		"show_shadows" : true,
		"show_particles" : true,
		
		# SOUND
		"music_vol" : 1,
		"sound_vol" : 1,
		"voice_vol" : 1,
		"show_subtitles" : true
	}
	
	for key in defaults:
		if not key in config:
			config[key] = defaults[key]

# And now some code to let us switch scenes easily:

func goto_scene(path):
    # This function will usually be called from a signal callback,
    # or some other function from the running scene.
    # Deleting the current scene at this point might be
    # a bad idea, because it may be inside of a callback or function of it.
    # The worst case will be a crash or unexpected behavior.

    # The way around this is deferring the load to a later time, when
    # it is ensured that no code from the current scene is running:
    call_deferred("_deferred_goto_scene",path)


func _deferred_goto_scene(path):

    # Immediately free the current scene,
    # there is no risk here.    
    current_scene.free()

    # Load new scene
    var s = ResourceLoader.load(path)

    # Instance the new scene
    current_scene = s.instance()

    # Add it to the active scene, as child of root
    get_tree().get_root().add_child(current_scene)

    #optional, to make it compatible with the SceneTree.change_scene() API
    get_tree().set_current_scene( current_scene )
