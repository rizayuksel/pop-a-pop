extends Area2D

var is_popped = false
var original_color: Color = Color(1, 1, 1, 1)

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

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
	
	_update_ui_score()
	
	var main_scene = get_tree().current_scene
	var ui = main_scene.get_node_or_null("UI")
	if ui:
		if ui.has_method("play_pop_sound"):
			ui.play_pop_sound()
			
		if ui.has_method("equip_ghost_arrow"):
			ui.equip_ghost_arrow()
			
	queue_free()

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
