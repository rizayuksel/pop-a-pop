extends Area2D 

const SPIKE_COUNT = 5
var spike_scene = preload("res://scenes/objects/spike.tscn")

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is RigidBody2D:
		if has_node("IceBarrier"):
			_play_ice_sound()
		else:
			pop()

func pop():
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI"):
		main_scene.get_node("UI").add_popped_balloon()

		if main_scene.get_node("UI").has_method("play_spike_sound"):
			main_scene.get_node("UI").play_spike_sound()
		
	var angle_step = 360.0 / SPIKE_COUNT

	for i in range(SPIKE_COUNT):
		var spike = spike_scene.instantiate()
		
		var fire_angle = deg_to_rad((i * angle_step) - 90.0) + global_rotation
		
		spike.global_position = global_position
		spike.rotation = fire_angle
		
		get_tree().current_scene.call_deferred("add_child", spike)
		
	queue_free()

func _play_ice_sound():
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI") and main_scene.get_node("UI").has_method("play_ice_hit_sound"):
		main_scene.get_node("UI").play_ice_hit_sound()

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
