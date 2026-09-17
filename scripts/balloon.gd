extends Area2D

var colors = [
	Color("8A9A5B"), # Green
	Color("87CEEB"), # Blue
	Color("E35335"), # Red
	Color("F4C430"), # Yellow
	Color("F8C8DC"), # Pink
	Color("DA70D6"), # Purple
	Color("F5DEB3")  # Brown
]

func _ready():
	$Sprite2D.modulate = colors.pick_random()
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
		
		if main_scene.get_node("UI").has_method("play_pop_sound"):
			main_scene.get_node("UI").play_pop_sound()
			
	queue_free()

func _play_deflect_sound():
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI") and main_scene.get_node("UI").has_method("play_ice_hit_sound"):
		main_scene.get_node("UI").play_ice_hit_sound()
