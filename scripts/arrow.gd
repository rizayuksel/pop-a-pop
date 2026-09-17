extends RigidBody2D

func _ready():
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	collision_mask = 1

func _process(_delta):
	if linear_velocity.length() > 0:
		rotation = linear_velocity.angle()
