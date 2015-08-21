extends KinematicBody

const MIN_REACTION_TIME = 100
const MAX_REACTION_TIME = 200
const MIN_SPEED = 2
const MAX_SPEED = 15

# the ghost is only active after the player triggers her
var active = false

# she always knows where the player is
var player = null

# she always goes towards where the player was
var target = null

var t = 0
var next_action_in = 20
var speed = 5

func _ready():
	player = get_node("../player")
	target = player.get_translation()

func _fixed_process (delta):
	t = t + 1
	if t > next_action_in:
		t = 0
		next_action_in = rand_range(MIN_REACTION_TIME, MAX_REACTION_TIME)
		
		# She's meant to chase you, not to catch you (unless you're careless). She goes after where you /were/
		target = player.get_translation()
		self.look_at (target, Vector3(0, 1, 0))
		speed = rand_range(MIN_SPEED, MAX_SPEED)
	
	# move towards her target
	var velocity = (target - self.get_translation()).normalized()
	self.move (velocity * delta * speed)

# The ghost lady is a poltergeist, if objects come in her field of influence, she tosses them everywhere with a loud "thwack" sound.
func _on_aura_body_enter( body ):	
	if active and body extends RigidBody and not body.is_in_group("player"):
		self.get_node("snd").play ("punch0" + str(int(rand_range(1, 5))))
		
		var mass = body.get_mass()
		var rnd = Vector3(rand_range(-50, 50) * mass, rand_range(-50, 50) * mass, rand_range(-50, 50) * mass)
		body.apply_impulse(Vector3(), rnd)

# The player takes damage if they touch the ghost
func _on_body_enter( body ):
	if active and body.is_in_group("player"):
		# Hurt the player
		player.hurt (25)
		
		# It's not fair to pick on the player /all/ the time, choose a new target and go away for a bit
		target = player.get_translation() + Vector3(rand_range(-50, 50), rand_range(0, 5), rand_range(-50, 50))
		t = 0
		next_action_in = rand_range(MIN_REACTION_TIME, MAX_REACTION_TIME)
		speed = 15

# The ghost lady wakes up angry
func activate ():
	if not active:
		active = true
		self.set_fixed_process (true)
		get_node("Particles").set_emitting(true)
		self.get_node("snd").play ("ghost0")

func deactivate ():
	active = false
	self.set_fixed_process (false)