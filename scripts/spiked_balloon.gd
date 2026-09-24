extends Area2D 

const SPIKE_COUNT = 5
var spike_scene = preload("res://scenes/objects/spike.tscn")
var popped_texture = preload("res://assets/textures/PoppedBalloon.png")

var is_popped = false
var fall_speed = 0.0

func _ready():
	body_entered.connect(_on_body_entered)

func _process(delta):
	if is_popped:
		fall_speed += 200.0 * delta
		position.y += fall_speed * delta

		var screen_height = get_viewport_rect().size.y
		if global_position.y > screen_height + 100:
			queue_free()

func _on_body_entered(body):
	if body is RigidBody2D:
		if has_node("IceBarrier"):
			_play_ice_sound()
		else:
			pop()

func pop():
	if is_popped:
		return
	is_popped = true
	
	if is_in_group("balloons"):
		remove_from_group("balloons")
		
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI"):
		main_scene.get_node("UI").add_popped_balloon()

		if main_scene.get_node("UI").has_method("play_spike_sound"):
			main_scene.get_node("UI").play_spike_sound()
		
	var angle_step = 360.0 / SPIKE_COUNT

	# 5 yeni çiviyi fırlat
	for i in range(SPIKE_COUNT):
		var spike = spike_scene.instantiate()
		var fire_angle = deg_to_rad((i * angle_step) - 90.0) + global_rotation
		
		spike.global_position = global_position
		spike.rotation = fire_angle
		
		get_tree().current_scene.call_deferred("add_child", spike)
		
	if has_node("Sprite2D"):
		$Sprite2D.texture = popped_texture
		$Sprite2D.modulate = Color("999999")
		$Sprite2D.scale = Vector2(0.1, 0.1)
		$Sprite2D.visible = true
		
	if has_node("FrozenSprite"):
		$FrozenSprite.visible = false
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", true)
		elif child != get_node_or_null("Sprite2D") and child != get_node_or_null("FrozenSprite"):
			if child is Node2D:
				child.visible = false
			if child is Area2D:
				child.queue_free()
			
	fall_speed = 100.0

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

	z_index = 100
	z_as_relative = false
	modulate = Color.WHITE

func custom_unfreeze():
	var normal_sprite = get_node_or_null("Sprite2D")
	var frozen_sprite = get_node_or_null("FrozenSprite")
	
	if normal_sprite and frozen_sprite:
		normal_sprite.visible = true
		frozen_sprite.visible = false
