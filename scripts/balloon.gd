extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is RigidBody2D:
		var main_scene = get_tree().current_scene
		if main_scene.has_node("UI"):
			main_scene.get_node("UI").add_popped_balloon()
			
		queue_free()
