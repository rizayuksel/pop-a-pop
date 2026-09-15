extends Area2D

const EXPLOSION_SCENE = preload("res://scenes/explosion_effect.tscn")
@export var explosion_radius = 200.0 

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is RigidBody2D:
		pop()

func pop():
	_update_ui_score()
	
	var main_scene = get_tree().current_scene
	var ui = main_scene.get_node_or_null("UI")
	if ui:
		if ui.has_method("play_fire_sound"):
			ui.play_fire_sound()
		if ui.has_method("shake_camera"):
			ui.shake_camera(18.0, 0.3)
			
	explode()
	spawn_explosion_effect()
	queue_free()

func explode():
	var all_balloons = get_tree().get_nodes_in_group("balloons")
	for target_balloon in all_balloons:
		if target_balloon != self and is_instance_valid(target_balloon):
			if global_position.distance_to(target_balloon.global_position) <= explosion_radius:
				if target_balloon.has_node("IceBarrier"):
					_unfreeze_balloon(target_balloon)
				else:
					_update_ui_score()
					target_balloon.queue_free()

func _unfreeze_balloon(balloon):
	var ice_barrier = balloon.get_node_or_null("IceBarrier")
	if ice_barrier:
		ice_barrier.queue_free()
	
	balloon.modulate = Color(1, 1, 1, 1)
	balloon.set_physics_process(true)
	balloon.set_process(true)
	
	if balloon is Area2D:
		balloon.set_deferred("monitoring", true)
		balloon.set_deferred("monitorable", true)

func spawn_explosion_effect():
	var effect = EXPLOSION_SCENE.instantiate()
	effect.global_position = global_position
	get_tree().current_scene.call_deferred("add_child", effect)

func _update_ui_score():
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI"):
		main_scene.get_node("UI").add_popped_balloon()
