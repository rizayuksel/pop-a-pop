extends RigidBody2D

var is_stuck = false
var flight_rotation: float = 0.0

func _ready():
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	collision_mask = 1

func _process(_delta):
	if is_stuck:
		return
		
	if linear_velocity.length() > 5.0:
		flight_rotation = linear_velocity.angle()
		rotation = flight_rotation

func stick():
	is_stuck = true
	set_process(false)

	rotation = flight_rotation 
	
	set_deferred("freeze", true)

	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
