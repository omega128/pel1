extends RigidBody

func _ready():
	# this item is carry-able
	self.add_to_group ("holdable")
