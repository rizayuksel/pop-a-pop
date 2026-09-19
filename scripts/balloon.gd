extends Area2D

var colors = [
	Color("8A9A5B"),
	Color("87CEEB"),
	Color("E35335"),
	Color("F4C430"),
	Color("F8C8DC"),
	Color("DA70D6"),
	Color("F5DEB3")
]

var popped_texture = preload("res://assets/textures/PoppedBalloon.png")
var is_popped = false
var fall_speed = 0.0

func _ready():
	$Sprite2D.modulate = colors.pick_random()
	body_entered.connect(_on_body_entered)

func _process(delta):
	if is_popped:
		fall_speed += 200.0 * delta
		position.y += fall_speed * delta

		var screen_height = get_viewport_rect().size.y
		if global_position.y > screen_height + 100:
			queue_free()

func _on_body_entered(body):
	if is_popped:
		return
		
	if body is RigidBody2D:
		if has_node("IceBarrier"):
			_play_deflect_sound()
		else:
			pop()

func pop():
	if is_popped:
		return
		
	is_popped = true
	if is_in_group("balloons"):
		remove_from_group("balloons")
		
	$Sprite2D.texture = popped_texture
	$Sprite2D.visible = true

	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", true)

	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI"):
		main_scene.get_node("UI").add_popped_balloon()
		
		if main_scene.get_node("UI").has_method("play_pop_sound"):
			main_scene.get_node("UI").play_pop_sound()

func _play_deflect_sound():
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI") and main_scene.get_node("UI").has_method("play_ice_hit_sound"):
		main_scene.get_node("UI").play_ice_hit_sound()
