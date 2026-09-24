extends Area2D

@export var freeze_radius = 120.0
var snow_texture = preload("res://assets/textures/SnowEffect.png")
var frozen_fire_texture = preload("res://assets/textures/FrozenFireBalloon.png")

var is_popped = false 

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _on_body_entered(body):
	if body is RigidBody2D:
		pop()

func _on_area_entered(area):
	if area is RigidBody2D:
		pop()

func pop():
	if is_popped:
		return
	is_popped = true
	
	_update_ui_score()

	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI") and main_scene.get_node("UI").has_method("play_ice_sound"):
		main_scene.get_node("UI").play_ice_sound()
		
	apply_freeze_effect()
	queue_free()

func pop_silently():
	if is_popped:
		return
	is_popped = true
	
	_update_ui_score()
	queue_free()

func apply_freeze_effect():
	var all_balloons = get_tree().get_nodes_in_group("balloons")

	for target_balloon in all_balloons:
		if target_balloon != self and is_instance_valid(target_balloon):

			var script = target_balloon.get_script()
			if script != null and script.resource_path.get_file() == "ice_balloon.gd":
				continue
				
			var dist = global_position.distance_to(target_balloon.global_position)
			
			if dist <= freeze_radius:
				var balloon_sprite = target_balloon.get_node_or_null("Sprite2D")
				if target_balloon.has_method("custom_freeze"):
					target_balloon.custom_freeze()
				elif balloon_sprite:
					balloon_sprite.modulate = balloon_sprite.modulate.lerp(Color.WHITE, 0.6)
						
				var snow_sprite = Sprite2D.new()
				snow_sprite.texture = snow_texture
				snow_sprite.name = "SnowEffectOverlay"
				snow_sprite.scale = Vector2(0.2, 0.2)
				snow_sprite.z_index = 16
				target_balloon.add_child(snow_sprite)
				
				target_balloon.set_physics_process(false)
				target_balloon.set_process(false)
				
				if target_balloon is Area2D:
					target_balloon.set_deferred("monitoring", false)
					target_balloon.set_deferred("monitorable", false)
				
				var static_body = StaticBody2D.new()
				static_body.name = "IceBarrier"
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

				var hit_detector = Area2D.new()
				hit_detector.name = "IceHitDetector"
				var hit_col = CollisionShape2D.new()

				if new_col.shape is CircleShape2D:
					var inflated_shape = CircleShape2D.new()
					inflated_shape.radius = new_col.shape.radius + 2.0
					hit_col.shape = inflated_shape
				else:
					hit_col.shape = new_col.shape
					
				hit_detector.add_child(hit_col)

				hit_detector.body_entered.connect(func(body):
					if body is RigidBody2D:
						var main = target_balloon.get_tree().current_scene
						if main.has_node("UI"):
							if main.get_node("UI").has_method("play_ice_hit_sound"):
								main.get_node("UI").play_ice_hit_sound()
							elif main.get_node("UI").has_method("play_ice_sound"):
								main.get_node("UI").play_ice_sound()
				)
				
				static_body.add_child(hit_detector)
				target_balloon.call_deferred("add_child", static_body)

func _update_ui_score():
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI"):
		main_scene.get_node("UI").add_popped_balloon()
