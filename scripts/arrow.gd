extends RigidBody2D

func _ready():
	# continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	collision_mask = 1

func _process(_delta):
	if linear_velocity.length() > 0:
		if has_node("Sprite2D"):
			$Sprite2D.rotation = linear_velocity.angle()
