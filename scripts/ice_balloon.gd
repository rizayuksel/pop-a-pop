extends Area2D

var freeze_radius = 200.0

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _on_body_entered(_body):
	_update_ui_score()
	apply_freeze_effect()
	queue_free()

func _on_area_entered(_area):
	_update_ui_score()
	apply_freeze_effect()
	queue_free()

func apply_freeze_effect():
	var all_balloons = get_tree().get_nodes_in_group("balloons")
	
	for target_balloon in all_balloons:
		if target_balloon != self and is_instance_valid(target_balloon):
			var dist = global_position.distance_to(target_balloon.global_position)
			
			if dist <= freeze_radius:
				target_balloon.modulate = Color(0.0, 0.8, 1.0, 0.9)
				
				target_balloon.set_physics_process(false)
				target_balloon.set_process(false)
				
				if target_balloon is Area2D:
					target_balloon.set_deferred("monitoring", false)
					target_balloon.set_deferred("monitorable", false)
				
				var static_body = StaticBody2D.new()
				static_body.collision_layer = 1
				static_body.collision_mask = 1
				
				var physics_mat = PhysicsMaterial.new()
				physics_mat.bounce = 0.8
				static_body.physics_material_override = physics_mat
				
				var new_col = CollisionShape2D.new()
				
				var existing_col = target_balloon.get_node_or_null("CollisionShape2D")
				if existing_col != null and existing_col.shape != null:
					new_col.shape = existing_col.shape
				else:
					var fallback_shape = CircleShape2D.new()
					fallback_shape.radius = 45.0
					new_col.shape = fallback_shape
				
				static_body.add_child(new_col)
				target_balloon.call_deferred("add_child", static_body)

func _update_ui_score():
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI"):
		main_scene.get_node("UI").add_popped_balloon()
