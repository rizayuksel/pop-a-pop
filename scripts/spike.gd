extends Area2D

@export var speed: float = 600.0
var has_hit: bool = false

func _ready():
	body_entered.connect(_handle_collision)
	area_entered.connect(_handle_collision)
	
	get_tree().create_timer(3.0).timeout.connect(queue_free)

func _process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _handle_collision(node):
	if has_hit or not is_instance_valid(node) or node == self:
		return
		
	var target = node
	if target.name == "IceBarrier" or target.name == "IceHitDetector":
		target = target.get_parent()
		
	var script = target.get_script()
	var script_name = script.resource_path.get_file() if script else ""
	
	if script_name == "mud.gd" or target.get("is_mud"):
		has_hit = true
		target.queue_free()
		queue_free()
		return
		
	if target.has_node("IceBarrier") or node.name == "IceBarrier" or node.name == "IceHitDetector":
		has_hit = true
		_play_ice_hit_sound()
		queue_free()
		return
		
	if target.has_method("pop"):
		has_hit = true
		target.pop()
		queue_free()
		return
	elif target.is_in_group("balloons"):
		has_hit = true
		target.queue_free() 
		queue_free()
		return
		
	if node is StaticBody2D:
		has_hit = true
		_play_ice_hit_sound()
		queue_free()
		return

func _play_ice_hit_sound():
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI") and main_scene.get_node("UI").has_method("play_ice_hit_sound"):
		main_scene.get_node("UI").play_ice_hit_sound()
