extends KinematicBody


# the ghost starts quiscient.
var active = false

var player = null # she always knows where the player is
var target = null # she always goes towards where the player was

# the ghost's reflexes aren't very sharp
var t = 0
var next_action_in = 20
var speed = 5

const MIN_REACTION_TIME = 100
const MAX_REACTION_TIME = 200
const MIN_SPEED = 2
const MAX_SPEED = 15

func _ready():
	player = get_node("../player")
	target = player.get_translation()

func _fixed_process (delta):
	# The ghost doesn't react very fast
	t = t + 1
	if t > next_action_in:
		t = 0
		next_action_in = rand_range(MIN_REACTION_TIME, MAX_REACTION_TIME)
		
		# She's meant to chase you, not to catch you (unless you're careless). She always goes after where you /were/
		target = player.get_translation()
		
		# How fast she goes anywhere is random
		speed = rand_range(MIN_SPEED, MAX_SPEED)
	
	# move her towards her target
	var velocity = (target - self.get_translation()).normalized()
	self.move (velocity * delta * speed)

# The ghost lady affects objects in a wide radius
func _on_aura_body_enter( body ):	
	if active and body extends RigidBody and not body.is_in_group("player"):
		# if objects come in her field of influence, she tosses them everywhere.
		var rnd = Vector3(rand_range(-50, 50) * mass, rand_range(-50, 50) * mass, rand_range(-50, 50) * body.get_mass())
		body.apply_impulse(Vector3(), rnd)
		
		# Make a loud noise
		self.get_node("snd").play ("punch0" + str(int(rand_range(1, 5))))

# The player takes damage if they touch the ghost directly
func _on_body_enter( body ):
	if active and body.is_in_group("player"):
		# Hurt the player
		player.hurt (25)
		
		# choose a new target and go away for a random amount of time before trying again
		target = player.get_translation() + Vector3(rand_range(-50, 50), rand_range(0, 5), rand_range(-50, 50))		
		next_action_in = rand_range(MIN_REACTION_TIME, MAX_REACTION_TIME)
		t = 0
		speed = 15

# The ghost lady wakes up angry
func activate ():
	if not active:
		active = true
		self.set_fixed_process (true)
		get_node("Particles").set_emitting(true)
		self.get_node("snd").play ("ghost0")

# We don't want her to kill the player if the player has already won the game
func deactivate ():
	active = false
	self.set_fixed_process (false)