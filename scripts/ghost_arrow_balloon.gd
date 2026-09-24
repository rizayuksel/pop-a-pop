extends Area2D

var is_popped = false
var original_color: Color = Color(1, 1, 1, 1)

var popped_texture = preload("res://assets/textures/PoppedBalloon.png")
var fall_speed = 0.0

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta):
	if is_popped:
		fall_speed += 200.0 * delta
		position.y += fall_speed * delta

		var screen_height = get_viewport_rect().size.y
		if global_position.y > screen_height + 100:
			queue_free()

func _on_body_entered(body):
	if body is RigidBody2D:
		pop()

func _on_area_entered(area):
	if area is RigidBody2D or area.name.contains("Arrow"):
		pop()

func pop():
	if is_popped:
		return
	is_popped = true
	
	if is_in_group("balloons"):
		remove_from_group("balloons")
	
	_update_ui_score()
	
	var main_scene = get_tree().current_scene
	var ui = main_scene.get_node_or_null("UI")
	if ui:
		if ui.has_method("play_pop_sound"):
			ui.play_pop_sound()
			
		if ui.has_method("equip_ghost_arrow"):
			ui.equip_ghost_arrow()

	if has_node("Sprite2D"):
		$Sprite2D.texture = popped_texture
		$Sprite2D.modulate = Color("95759e")
		$Sprite2D.scale = Vector2(0.1, 0.1)
		$Sprite2D.visible = true
		
	if has_node("FrozenSprite"):
		$FrozenSprite.visible = false

	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", true)

	fall_speed = 100.0

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

func _update_ui_score():
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI"):
		main_scene.get_node("UI").add_popped_balloon()
