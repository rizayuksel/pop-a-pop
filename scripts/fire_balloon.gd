extends Area2D

const EXPLOSION_SCENE = preload("res://scenes/objects/explosion_effect.tscn")
@export var explosion_radius = 120.0 

var original_color: Color 
var is_popped = false 

func _ready():
	if has_node("Sprite2D"):
		original_color = $Sprite2D.modulate
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is RigidBody2D:
		pop()

func pop():
	if is_popped:
		return
	is_popped = true
	
	var main_scene = get_tree().current_scene
	var ui = main_scene.get_node_or_null("UI")
	if ui:
		if ui.has_method("play_fire_sound"):
			ui.play_fire_sound()
		if ui.has_method("shake_camera"):
			ui.shake_camera(18.0, 0.3)
		ui.add_popped_balloon()
			
	explode()
	spawn_explosion_effect()
	queue_free()

func explode():
	var all_targets = []
	
	var all_balloons = get_tree().get_nodes_in_group("balloons")
	for balloon in all_balloons:
		if balloon != self and is_instance_valid(balloon):
			if global_position.distance_to(balloon.global_position) <= explosion_radius:
				all_targets.append(balloon)
				
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = explosion_radius
	query.shape = shape
	query.transform = Transform2D(0, global_position)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var hits = space_state.intersect_shape(query)
	for hit in hits:
		var target = hit.collider
		if is_instance_valid(target) and target != self and not all_targets.has(target):
			all_targets.append(target)
			
	for target in all_targets:
		_process_target(target)

func _process_target(target):
	if target.name == "IceBarrier" or target.name == "IceHitDetector":
		target = target.get_parent()
		
	if not is_instance_valid(target) or target == self:
		return

	if target.has_node("IceBarrier") or target.get("is_frozen"):
		_unfreeze_balloon(target)
		if "is_frozen" in target:
			target.is_frozen = false

	# Doğrudan Sessiz Patlatma Kontrolü
	if target.has_method("pop_silently"):
		target.pop_silently()
		return

	var script = target.get_script()
	var script_name = script.resource_path.get_file() if script else ""

	if target.has_method("pop"):
		if script_name == "fire_balloon.gd":
			get_tree().create_timer(0.15).timeout.connect(func():
				if is_instance_valid(target):
					target.pop()
			)
		elif script_name == "laser_balloon.gd" or script_name == "spiked_balloon.gd":
			var main_scene = get_tree().current_scene
			if main_scene.has_node("UI"):
				main_scene.get_node("UI").add_popped_balloon()
			target.queue_free()
		else:
			target.pop()
			if is_instance_valid(target) and target.has_method("pop"):
				var popped = target.get("is_popped")
				if popped == false or popped == null:
					target.pop()
	else:
		if script_name == "mud.gd" or target.get("is_mud"):
			target.queue_free()
		elif target.is_in_group("balloons"):
			var main_scene = get_tree().current_scene
			if main_scene.has_node("UI"):
				main_scene.get_node("UI").add_popped_balloon()
			target.queue_free()

func _unfreeze_balloon(balloon):
	var ice_barrier = balloon.get_node_or_null("IceBarrier")
	if ice_barrier:
		balloon.remove_child(ice_barrier) 
		ice_barrier.queue_free()
		
	var snow_overlay = balloon.get_node_or_null("SnowEffectOverlay")
	if snow_overlay:
		balloon.remove_child(snow_overlay)
		snow_overlay.queue_free()

	var balloon_sprite = balloon.get_node_or_null("Sprite2D")
	if balloon_sprite:
		if "original_color" in balloon:
			balloon_sprite.modulate = balloon.original_color
		else:
			balloon_sprite.modulate = Color(1, 1, 1, 1)

	if balloon.has_method("custom_unfreeze"):
		balloon.custom_unfreeze()

	balloon.set_physics_process(true)
	balloon.set_process(true)

	if balloon is Area2D:
		balloon.set_deferred("monitoring", true)
		balloon.set_deferred("monitorable", true)

func custom_freeze():
	var normal_sprite = get_node_or_null("Sprite2D")
	var frozen_sprite = get_node_or_null("FrozenSprite")

	if normal_sprite:
		normal_sprite.visible = false
		
	if frozen_sprite:
		frozen_sprite.visible = true
		frozen_sprite.modulate = Color.WHITE

func custom_unfreeze():
	var normal_sprite = get_node_or_null("Sprite2D")
	var frozen_sprite = get_node_or_null("FrozenSprite")
	if normal_sprite and frozen_sprite:
		normal_sprite.visible = true
		frozen_sprite.visible = false

func spawn_explosion_effect():
	var effect = EXPLOSION_SCENE.instantiate()
	effect.global_position = global_position
	effect.modulate = Color(1.0, 0.5, 0.0) 
	get_tree().current_scene.call_deferred("add_child", effect)
