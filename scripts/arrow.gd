extends RigidBody2D

func _process(_delta):
	if linear_velocity.length() > 0:
		rotation = linear_velocity.angle()
