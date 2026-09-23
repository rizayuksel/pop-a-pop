extends RigidBody2D

var is_flying = false

func _physics_process(_delta):
	if is_flying and linear_velocity.length() > 5.0:
		rotation = linear_velocity.angle()

func shoot(impulse_vector: Vector2):
	apply_central_impulse(impulse_vector)
	is_flying = true
	
	get_tree().create_timer(6.0).timeout.connect(queue_free)
