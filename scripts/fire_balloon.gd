extends Area2D

const EXPLOSION_SCENE = preload("res://scenes/explosion_effect.tscn")
var explosion_radius = 200.0 

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is RigidBody2D:
		_update_ui_score()
		explode()
		spawn_explosion_effect()
		queue_free()

func explode():
	var all_balloons = get_tree().get_nodes_in_group("balloons")
	for target_balloon in all_balloons:
		if target_balloon != self and is_instance_valid(target_balloon):
			if global_position.distance_to(target_balloon.global_position) <= explosion_radius:
				_update_ui_score()
				target_balloon.queue_free()

func spawn_explosion_effect():
	var effect = EXPLOSION_SCENE.instantiate()
	effect.global_position = global_position
	get_tree().current_scene.add_child(effect)

func _update_ui_score():
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI"):
		main_scene.get_node("UI").add_popped_balloon()
