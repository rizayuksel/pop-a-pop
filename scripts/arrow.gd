extends RigidBody2D

func _ready():
	# Prevent the arrow from tunneling through objects at high speeds
	continuous_cd = 1
	
	# Force the arrow to physically recognize and collide with Layer 1
	collision_mask = 1

func _process(_delta):
	if linear_velocity.length() > 0:
		rotation = linear_velocity.angle()
