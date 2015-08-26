extends RigidBody

# Walking
export var can_move = false
var walk_speed = 0
const max_accel = 0.005
const air_accel = 0.02

# Perspective
export var yaw = 0
export var pitch = 0

# Holding Things
var holding = null # This is a pointer to the currently held object's node. When nothing is held, it is set to 'null'
var hold_pos = null # this is a pointer to a Spatial marking the distance from the camera an object is held at

# System configuration
var config

# You have 100 health at start.
var health = 100

func _ready():
	hold_pos = get_node("yaw/camera/in_front")
	config = get_node("/root/global").config
	
	# when looking at things, don't get in our own way.
	get_node("yaw/camera/looking_at").add_exception(self)
	get_node("ray").add_exception(self)
	
	# We need to pay attention to the keyboard
	set_process_input(true)

	# we want the mouse, too.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# 60 FPS or bust.
	set_fixed_process(true)
	OS.set_iterations_per_second(60)
	
func _input(event):
	if event.type == InputEvent.MOUSE_MOTION and can_move:
		#yaw = fmod(yaw - event.relative_x * view_sensitivity, 360)
		yaw = fmod(yaw - event.relative_x * config["mouse_sensitivity"], 360)
		
		# Quake-like minimum pitch -80, maximum pitch 70:
		pitch = max(min(pitch - event.relative_y * config["mouse_sensitivity"], 70), -80)
		get_node("yaw").set_rotation(Vector3(0, deg2rad(yaw), 0))
		get_node("yaw/camera").set_rotation(Vector3(deg2rad(pitch), 0, 0))
		
	# if you pause the game, show the mouse and the pause dialogue,
	if Input.is_action_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().set_pause(true)
		get_node("pause_dialog").show()
		
	# if you try to quit the game, we pause, show the mouse, and bring up a y/n "are you sure?" dialog
	if Input.is_action_pressed("quit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().set_pause(true)
		get_node("quit_dialog").show()

	# We do the same thing for game options, except it's stored in it's own scene file
	if Input.is_action_pressed("show_settings"):#
		var settings = load("res://gui/settings.scn").instance()
		get_tree().get_current_scene().add_child(settings)

func _fixed_process (delta):
	# as long as the user is holding an object, keep it in front of the camera
	if holding:
		holding.set_translation (hold_pos.get_global_transform().origin)

func _integrate_forces(state):
	var aim = get_node("yaw").get_global_transform().basis
	var direction = Vector3()

	if can_move:
		if Input.is_action_pressed("use"):
			if not holding:
				# cast a ray to find what we're looking at
				if get_node("yaw/camera/looking_at").is_colliding():
					var thing = get_node("yaw/camera/looking_at").get_collider()
					
					# if we find something holdable, pick it up
					if thing.is_in_group("holdable"):
						holding = thing
						holding.set_linear_velocity (Vector3(0, 0, 0))
					
					# if we're in front of a ladder, start climbing
					if thing.is_in_group("climbable"):
						#direction += Vector3(0, 1, 0)
						apply_impulse(Vector3(), Vector3(0, 0.65, 0) * get_mass())
						
		else:
			# if the key is not held, but whe're still holding an item, drop it
			if holding:
				holding.set_linear_velocity (Vector3(0, 0, 0))
				holding = null
	
		# WSAD are very useful.
		if Input.is_action_pressed("move_forward"):
			direction -= aim[2]
		if Input.is_action_pressed("move_backward"):
			direction += aim[2]
		if Input.is_action_pressed("move_left"):
			direction -= aim[0]
		if Input.is_action_pressed("move_right"):
			direction += aim[0]
	
		# Now that we're done getting input, move the player
		direction = direction.normalized()
		apply_impulse(Vector3(), direction * get_mass())

	state.integrate_forces()
	
func hurt (damage):	
	# If you're already dying, you can't be hurt, so don't start the animation again.
	if health <= 0:
		return
	
	# Remove health
	health -= damage
	
	# When hit, you drop what you're carrying
	holding = null
	
	if health <= 0:
		# When the player dies, we toss them around, make the ghost sound and fade out before taking them to the credits.
		can_move = false		
		var rnd = Vector3(rand_range(-50, 50), rand_range(0, 5), rand_range(-50, 50))
		set_linear_velocity (rnd)
		set_angular_velocity (Vector3(1, 1, 1))
		get_node("../anim").play("closing")
		self.get_node("snd").play ("ghost0")
	else:
		# As the player gets more damaged, their vision loses saturation to show it
		get_node("yaw/camera").get_environment().fx_set_param(Environment.FX_PARAM_BCS_SATURATION, (health / 100.00))
		
		# Toss the player around
		var rnd = Vector3(rand_range(-50, 50), rand_range(0, 5), rand_range(-50, 50))
		set_linear_velocity (rnd)
		
		# Fade the screen in and out
		get_node("../anim").play("woozy")
		
		# The player's "take damage" sound is currently the same as the "we've just been kicked" noise.
		self.get_node("snd").play ("punch0" + str(int(rand_range(1, 5))))

# Show a message on the screen
func show_toast (message):
	var toast = get_node("toast")
	toast.set_opacity(0)
	toast.set_text(message)
	get_node("anim").play("show_toast")

# When the player wants to leave, fix the mouse, unpause the game, and take us back to the menu
func _on_quit_dialog_confirmed():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().set_pause(false)
	get_node("/root/global").goto_scene("res://gui/menu.scn")

# after hiding a dialog box, return us to the game
func _on_dialog_hide():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().set_pause(false)