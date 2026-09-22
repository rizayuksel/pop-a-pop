extends Area2D

@export var speed: float = 600.0
var can_bounce: bool = true

func _ready():
	body_entered.connect(_handle_collision)
	area_entered.connect(_handle_collision)
	
	get_tree().create_timer(3.0).timeout.connect(queue_free)

func _process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _handle_collision(node):
	if not is_instance_valid(node) or node == self:
		return
		
	var script = node.get_script()
	var script_name = script.resource_path.get_file() if script else ""
	
	if script_name == "mud.gd" or node.get("is_mud"):
		node.queue_free()
		queue_free()
		return
		
	if node.name == "IceBarrier" or node.name == "IceHitDetector" or node is StaticBody2D:
		_bounce_spike(node)
		return
		
	if node.has_method("pop"):
		if node.has_node("IceBarrier"):
			_bounce_spike(node)
		else:
			node.pop()
			queue_free()

func _bounce_spike(hit_node):
	if not can_bounce:
		return
		
	var normal = Vector2.ZERO
	
	if hit_node.name == "IceBarrier" or hit_node.name == "IceHitDetector" or hit_node.has_node("IceBarrier"):
		var center = hit_node.global_position
		if hit_node.name == "IceHitDetector":
			center = hit_node.get_parent().global_position
		normal = (global_position - center).normalized()
	else:
		var space_state = get_world_2d().direct_space_state
		var current_dir = Vector2.RIGHT.rotated(rotation)
		var query = PhysicsRayQueryParameters2D.create(global_position - current_dir * 20.0, global_position + current_dir * 20.0)
		var result = space_state.intersect_ray(query)
		
		if result:
			normal = result.normal
		else:
			normal = -current_dir
	
	if normal != Vector2.ZERO:
		var current_dir = Vector2.RIGHT.rotated(rotation)
		var bounce_dir = current_dir.bounce(normal)
		rotation = bounce_dir.angle()
		
		position += bounce_dir * 15.0
		
	_play_ice_hit_sound()
	
	can_bounce = false
	get_tree().create_timer(0.05).timeout.connect(func(): can_bounce = true)

func _play_ice_hit_sound():
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI") and main_scene.get_node("UI").has_method("play_ice_hit_sound"):
		main_scene.get_node("UI").play_ice_hit_sound()
