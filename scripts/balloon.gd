extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is RigidBody2D:
		if has_node("IceBarrier"):
			_play_deflect_sound()
		else:
			pop()

func pop():
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI"):
		main_scene.get_node("UI").add_popped_balloon()
		
	queue_free()

func _play_deflect_sound():
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI") and main_scene.get_node("UI").has_method("play_ice_sound"):
		main_scene.get_node("UI").play_ice_sound()
