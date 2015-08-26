extends Node

# this will store system settings
export var config = {}

const CONFIG_FILENAME = "user://config.bin"

# We need to track the current scene, so we can easily switch between scenes in-game.
var current_scene = null

func _ready ():
	# let's do some bookkeeping, so we can change scenes at will
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )
	
	# load the user configuration from a file
	load_config()

# Set the config file to default values
func _set_default_config ():
	config = {
		# VIDEO
		"show_shadows" : true,
		"show_particles" : true,
		
		# SOUND
		"music_vol" : 1,
		"sound_vol" : 1,
		"voice_vol" : 1,
		"show_subtitles" : true,
		
		# INPUT
		"mouse_sensitivity" : 0.25
	}
	
# Save the user configuration to disk
func save_config ():
	var f = File.new()
	var err = f.open(CONFIG_FILENAME, File.WRITE)
	f.store_var( config )
	f.close()
	
# Load the user configuration from disk
func load_config ():
	var f = File.new()
	var err = f.open(CONFIG_FILENAME, File.READ)
	if err == 0:
		config = f.get_var()
		f.close()
	else:
		print ("Could not load config file, using default values.")
		_set_default_config()

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
