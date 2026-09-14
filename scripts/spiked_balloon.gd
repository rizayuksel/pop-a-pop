extends Area2D 

const SPIKE_COUNT = 5
var spike_scene = preload("res://scenes/spike.tscn")

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is RigidBody2D:
		pop()

func pop():
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI"):
		main_scene.get_node("UI").add_popped_balloon()
		
	var angle_step = 360.0 / SPIKE_COUNT

	for i in range(SPIKE_COUNT):
		var spike = spike_scene.instantiate()
		
		# 0 derecenin sağa bakması sorununu çözmek için -90 ekledik
		var fire_angle = deg_to_rad((i * angle_step) - 90.0) + global_rotation
		
		spike.global_position = global_position
		spike.rotation = fire_angle
		
		get_tree().current_scene.call_deferred("add_child", spike)
		
	queue_free()
