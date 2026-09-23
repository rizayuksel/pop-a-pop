extends Area2D

var is_mud = true

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is RigidBody2D:
		if body.name.begins_with("Ghost") or body.scene_file_path.contains("ghost_arrow"):
			return
			
		if body.has_method("stick"):
			body.stick()
			
		body.set_deferred("linear_velocity", Vector2.ZERO)
		body.set_deferred("angular_velocity", 0.0)
		body.set_deferred("gravity_scale", 0.0)

		var timer = get_tree().create_timer(0.3)
		timer.timeout.connect(func():
			if is_instance_valid(body):
				body.queue_free()
		)

		await timer.timeout
		queue_free()

func pop():
	queue_free()
