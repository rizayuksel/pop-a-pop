@tool
extends Area2D

enum LaserType { HORIZONTAL, VERTICAL, CROSS }

const TEX_HORIZONTAL = preload("res://assets/textures/LaserBalloon1.png") 
const TEX_VERTICAL = preload("res://assets/textures/LaserBalloon2.png")
const TEX_CROSS = preload("res://assets/textures/LaserBalloon3.png")

@export var laser_type: LaserType = LaserType.HORIZONTAL:
	set(value):
		laser_type = value
		_update_texture()

@export var laser_range: float = 2000.0

const SPARK_SCENE = preload("res://scenes/objects/laser_spark.tscn")

func _ready():
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)
		if has_node("LaserBeam"):
			$LaserBeam.visible = false
	
	_update_texture()

func _update_texture():
	if not has_node("Sprite2D"):
		return
		
	match laser_type:
		LaserType.HORIZONTAL:
			$Sprite2D.texture = TEX_HORIZONTAL
		LaserType.VERTICAL:
			$Sprite2D.texture = TEX_VERTICAL
		LaserType.CROSS:
			$Sprite2D.texture = TEX_CROSS

func _on_body_entered(body):
	if body is RigidBody2D:
		pop()

func pop():
	_update_ui_score()

	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI") and main_scene.get_node("UI").has_method("play_laser_sound"):
		main_scene.get_node("UI").play_laser_sound()
		
	fire_lasers()

	$Sprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)

	var tween = create_tween()
	tween.set_parallel(true)

	for child in get_children():
		if child is Line2D and child.visible:
			tween.tween_property(child, "width", 0.0, 0.4)

	await tween.finished
	queue_free()

func fire_lasers():
	var directions = []

	if laser_type == LaserType.HORIZONTAL or laser_type == LaserType.CROSS:
		directions.append(Vector2.LEFT)
		directions.append(Vector2.RIGHT)
	if laser_type == LaserType.VERTICAL or laser_type == LaserType.CROSS:
		directions.append(Vector2.UP)
		directions.append(Vector2.DOWN)
		
	var space_state = get_world_2d().direct_space_state
		
	for dir in directions:
		var start_pos = global_position
		var end_pos = global_position + (dir * laser_range)
		
		var current_exclude = [self.get_rid()]
		var beam_end_point = dir * laser_range 
		
		for i in range(30):
			var query = PhysicsRayQueryParameters2D.create(start_pos, end_pos)
			query.collide_with_areas = true  
			query.collide_with_bodies = true
			query.exclude = current_exclude
			
			var result = space_state.intersect_ray(query)
			
			if result:
				var hit_obj = result.collider
				var target = hit_obj
				
				if hit_obj.name == "IceBarrier":
					target = hit_obj.get_parent()
					
				if target.has_method("pop"):
					process_laser_hit(hit_obj)
					current_exclude.append(result.rid)
					spawn_spark(target.global_position)
				else:
					var script_path = ""
					if target.get_script() != null:
						script_path = target.get_script().resource_path.get_file()
						
					if script_path == "arrow.gd" or script_path == "spike.gd":
						current_exclude.append(result.rid)
					else:
						beam_end_point = to_local(result.position)
						spawn_spark(result.position)
						break
			else:
				break
				
		var beam = $LaserBeam.duplicate()
		beam.clear_points()
		beam.add_point(Vector2.ZERO)
		beam.add_point(beam_end_point)
		beam.visible = true
		beam.default_color = Color(0.0, 1.0, 1.0, 1.0)
		add_child(beam)

func process_laser_hit(hit_obj):
	var target = hit_obj
	
	if hit_obj.name == "IceBarrier":
		target = hit_obj.get_parent()
		
	if target.has_method("pop"):
		var script_path = ""
		if target.get_script() != null:
			script_path = target.get_script().resource_path.get_file()
			
		if script_path == "mud.gd":
			target.queue_free()
		else:
			silent_destroy_balloon(target)

func silent_destroy_balloon(balloon):
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI"):
		main_scene.get_node("UI").add_popped_balloon()
	balloon.queue_free()

func _update_ui_score():
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI"):
		main_scene.get_node("UI").add_popped_balloon()

func spawn_spark(spawn_pos: Vector2):
	var spark = SPARK_SCENE.instantiate()
	spark.global_position = spawn_pos
	get_tree().current_scene.call_deferred("add_child", spark)
