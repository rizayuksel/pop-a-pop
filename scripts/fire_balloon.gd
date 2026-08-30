extends Area2D

# Menzili test etmek için 150'den 400'e çıkardık
var explosion_radius = 400.0 

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is RigidBody2D:
		explode()
		queue_free()

func explode():
	var all_balloons = get_tree().get_nodes_in_group("balloons")
	
	for target_balloon in all_balloons:
		if target_balloon != self and is_instance_valid(target_balloon):
			var distance = global_position.distance_to(target_balloon.global_position)
			
			if distance <= explosion_radius:
				target_balloon.queue_free()
