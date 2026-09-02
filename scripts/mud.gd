extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is RigidBody2D:
		body.linear_velocity = Vector2.ZERO
		body.angular_velocity = 0.0
		body.gravity_scale = 0.0
		
		await get_tree().create_timer(0.3).timeout
		
		if is_instance_valid(body):
			body.queue_free()
		queue_free()
