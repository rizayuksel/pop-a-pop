extends RigidBody2D

var is_flying = false
var hit_targets = []

func _ready():
	contact_monitor = true
	max_contacts_reported = 10
	body_entered.connect(_on_hit_something)
	
	var area = Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 4294967295
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 60.0
	shape.shape = circle
	area.add_child(shape)
	add_child(area)
	
	area.body_entered.connect(_on_hit_something)
	area.area_entered.connect(_on_hit_something)

func _on_hit_something(node):
	if not is_instance_valid(node):
		return
		
	var target = node
	
	if "IceBarrier" in target.name or "IceHitDetector" in target.name:
		if target.get_parent() != null:
			target = target.get_parent()
	elif not target.has_method("pop") and target.get("is_mud") == null:
		if target.get_parent() != null and target.get_parent().has_method("pop"):
			target = target.get_parent()
			
	if not is_instance_valid(target) or target in hit_targets:
		return
		
	var is_balloon = target.has_method("pop") or target.has_method("pop_silently")
	var is_mud = target.get("is_mud") != null and target.is_mud
	
	if not is_balloon and not is_mud:
		return
		
	hit_targets.append(target)
	
	_disable_collisions_recursively(target)
	if node != target:
		_disable_collisions_recursively(node)
		
	if is_mud:
		target.queue_free()
		return
		
	if is_balloon:
		var is_frozen = target.get("is_frozen") == true or target.has_node("IceBarrier")
		var script = target.get_script()
		var script_name = script.resource_path.get_file().to_lower() if script else ""
		var node_name = target.name.to_lower()
		var is_ice_balloon = "ice_balloon" in script_name or "iceballoon" in script_name or ("ice" in node_name and "balloon" in node_name)
		
		if is_frozen or is_ice_balloon or target.has_method("pop_silently"):
			var main_scene = get_tree().current_scene
			if main_scene and main_scene.has_node("UI"):
				main_scene.get_node("UI").add_popped_balloon()
			target.queue_free()
		else:
			target.pop()

func _disable_collisions_recursively(obj: Node):
	if not is_instance_valid(obj):
		return
	if obj is CollisionObject2D:
		if obj is PhysicsBody2D:
			add_collision_exception_with(obj)
		obj.set_deferred("collision_layer", 0)
		obj.set_deferred("collision_mask", 0)
	for child in obj.get_children():
		_disable_collisions_recursively(child)

func _physics_process(delta):
	if is_flying and linear_velocity.length() > 5.0:
		rotation = linear_velocity.angle()
		
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(global_position, global_position + linear_velocity * delta * 15.0)
		query.collide_with_areas = true
		query.collide_with_bodies = true
		var result = space_state.intersect_ray(query)
		
		if result and result.collider:
			_on_hit_something(result.collider)

func shoot(velocity_vector: Vector2):
	linear_velocity = velocity_vector
	is_flying = true
	
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_node("UI"):
		var ui = main_scene.get_node("UI")
		if ui.has_node("CannonballSound"): 
			ui.get_node("CannonballSound").play()
		if ui.has_method("shake_camera"):
			ui.shake_camera(10.0, 0.2)
	
	get_tree().create_timer(6.0).timeout.connect(queue_free)
