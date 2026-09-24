@tool
extends Area2D

enum LaserType { HORIZONTAL, VERTICAL, CROSS }

const TEX_HORIZONTAL = preload("res://assets/textures/LaserBalloon1.png") 
const TEX_VERTICAL = preload("res://assets/textures/LaserBalloon2.png")
const TEX_CROSS = preload("res://assets/textures/LaserBalloon3.png")

const FROZEN_TEX_HORIZONTAL = preload("res://assets/textures/FrozenLaserBalloon1.png") 
const FROZEN_TEX_VERTICAL = preload("res://assets/textures/FrozenLaserBalloon2.png")
const FROZEN_TEX_CROSS = preload("res://assets/textures/FrozenLaserBalloon3.png")

@export var laser_type: LaserType = LaserType.HORIZONTAL:
	set(value):
		laser_type = value
		_update_texture()

@export var laser_range: float = 2000.0

const SPARK_SCENE = preload("res://scenes/objects/laser_spark.tscn")

var is_popped = false

func _ready():
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)
		if has_node("LaserBeam"):
			$LaserBeam.visible = false
	
	_update_texture()

func _update_texture():
	if has_node("Sprite2D"):
		match laser_type:
			LaserType.HORIZONTAL:
				$Sprite2D.texture = TEX_HORIZONTAL
			LaserType.VERTICAL:
				$Sprite2D.texture = TEX_VERTICAL
			LaserType.CROSS:
				$Sprite2D.texture = TEX_CROSS
				
	if has_node("FrozenSprite"):
		match laser_type:
			LaserType.HORIZONTAL:
				$FrozenSprite.texture = FROZEN_TEX_HORIZONTAL
			LaserType.VERTICAL:
				$FrozenSprite.texture = FROZEN_TEX_VERTICAL
			LaserType.CROSS:
				$FrozenSprite.texture = FROZEN_TEX_CROSS

func _on_body_entered(body):
	if body is RigidBody2D:
		pop()

func pop():
	if is_popped:
		return
	is_popped = true

	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI"):
		var ui = main_scene.get_node("UI")
		ui.add_popped_balloon()
		if ui.has_method("play_laser_sound"):
			ui.play_laser_sound()
		
	fire_lasers()

	if has_node("Sprite2D"):
		$Sprite2D.visible = false
	if has_node("FrozenSprite"):
		$FrozenSprite.visible = false
		
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
				var target = result.collider
				
				# Hedef buz engeli ise asıl balonu hedef alıyoruz
				if target.name == "IceBarrier" or target.name == "IceHitDetector":
					target = target.get_parent()
					
				if target.has_method("pop") or target.has_method("pop_silently"):
					process_laser_hit(target)
					current_exclude.append(result.rid)
					spawn_spark(target.global_position)
				else:
					var script_path = ""
					if target.get_script() != null:
						script_path = target.get_script().resource_path.get_file()
						
					if script_path == "arrow.gd" or script_path == "spike.gd":
						current_exclude.append(result.rid)
					elif script_path == "mud.gd" or target.get("is_mud"):
						target.queue_free()
						current_exclude.append(result.rid)
						spawn_spark(target.global_position)
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

func process_laser_hit(target):
	if not is_instance_valid(target) or target == self:
		return

	var script = target.get_script()
	var script_name = script.resource_path.get_file() if script else ""

	# 1. Buz üreten ana balonu sessizce yok et
	if target.has_method("pop_silently") or script_name == "ice_balloon.gd":
		if target.has_method("pop_silently"):
			target.pop_silently()
		else:
			var main_scene = get_tree().current_scene
			if main_scene.has_node("UI"):
				main_scene.get_node("UI").add_popped_balloon()
			target.queue_free()
		return

	# 2. Donmuş hedefi buzdan temizle (balonun kendisini kurtar)
	if target.has_node("IceBarrier") or target.get("is_frozen"):
		_unfreeze_balloon(target)
		if "is_frozen" in target:
			target.is_frozen = false

	# 3. Temizlenmiş hedefi özelliğine göre tetikle veya yok et
	if script_name == "laser_balloon.gd":
		get_tree().create_timer(0.15).timeout.connect(func():
			if is_instance_valid(target) and target.has_method("pop"):
				target.pop()
		)
	elif script_name == "fire_balloon.gd" or script_name == "triple_arrow_balloon.gd":
		if target.has_method("pop"):
			target.pop()
	else:
		if target.has_method("pop"):
			target.pop()
			# Balon hala patlamadıysa (is_popped == false), onu zorla patlat
			if is_instance_valid(target) and target.has_method("pop"):
				var popped = target.get("is_popped")
				if popped == false or popped == null:
					target.pop()

func _unfreeze_balloon(balloon):
	var ice_barrier = balloon.get_node_or_null("IceBarrier")
	if ice_barrier:
		balloon.remove_child(ice_barrier) 
		ice_barrier.queue_free()
		
	var snow_overlay = balloon.get_node_or_null("SnowEffectOverlay")
	if snow_overlay:
		balloon.remove_child(snow_overlay)
		snow_overlay.queue_free()

	var balloon_sprite = balloon.get_node_or_null("Sprite2D")
	if balloon_sprite:
		if "original_color" in balloon:
			balloon_sprite.modulate = balloon.original_color
		else:
			balloon_sprite.modulate = Color(1, 1, 1, 1)

	if balloon.has_method("custom_unfreeze"):
		balloon.custom_unfreeze()

	balloon.set_physics_process(true)
	balloon.set_process(true)

	if balloon is Area2D:
		balloon.set_deferred("monitoring", true)
		balloon.set_deferred("monitorable", true)

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

func spawn_spark(spawn_pos: Vector2):
	var spark = SPARK_SCENE.instantiate()
	spark.global_position = spawn_pos
	get_tree().current_scene.call_deferred("add_child", spark)
