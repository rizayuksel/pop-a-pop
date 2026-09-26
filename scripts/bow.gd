extends Sprite2D

signal arrow_shot

const ARROW_SCENE = preload("res://scenes/objects/arrow.tscn")
const MAX_DRAG_LENGTH = 150.0
const SMOOTH_SPEED = 25.0
const CANNON_MUZZLE_OFFSET = Vector2(80.0, -25.0)

var is_dragging = false
var drag_start_position = Vector2.ZERO
var is_active = true
var base_scale = Vector2.ONE
var loaded_arrow_base_scale = Vector2.ONE

var is_ghost_loaded = false
var is_cannon_loaded = false
var is_switching = false 
var scale_tween: Tween

var tex_normal_arrow = preload("res://assets/textures/Arrow.png")
var tex_ghost_arrow = preload("res://assets/textures/GhostArrow.png")

var current_pull_distance = 0.0
var target_rotation = 0.0

@onready var bow_string = $BowString
@onready var loaded_arrow = $LoadedArrow
@onready var trajectory_line = $Line2D
@onready var cannon_sprite = $CannonBall

@export var trajectory_length: int = 80

var top_tip = Vector2(-20, -130) 
var bottom_tip = Vector2(-20, 120)

var main_ui = null

func _ready():
	base_scale = scale
	loaded_arrow_base_scale = loaded_arrow.scale
	trajectory_line.top_level = true
	trajectory_line.global_position = Vector2.ZERO
	hide_trajectory()
	
	if cannon_sprite:
		cannon_sprite.visible = false
		
	_reset_bow_string()
	
	var current_scene = get_tree().current_scene
	if current_scene:
		main_ui = current_scene.get_node_or_null("UI")

func _reset_bow_string():
	bow_string.clear_points()
	bow_string.add_point(top_tip)
	bow_string.add_point(Vector2(-20, 0))
	bow_string.add_point(bottom_tip)

func _process(delta):
	_check_weapon_switch()
	
	if is_cannon_loaded:
		bow_string.visible = false
		loaded_arrow.visible = false
	elif not is_switching:
		bow_string.visible = true
	
	if is_dragging and is_active and not is_switching:
		var current_pos = get_viewport().get_mouse_position()
		var drag_vector = drag_start_position - current_pos
		
		if drag_vector.length() > 5.0:
			var target_pull = drag_vector.limit_length(MAX_DRAG_LENGTH).length()
			
			target_rotation = drag_vector.angle()
			rotation = lerp_angle(rotation, target_rotation, SMOOTH_SPEED * delta)
			current_pull_distance = lerp(current_pull_distance, target_pull, SMOOTH_SPEED * delta)
			
			if not is_cannon_loaded:
				bow_string.set_point_position(1, Vector2(-current_pull_distance, 0))
				loaded_arrow.position = Vector2(-current_pull_distance, 0)
			
			if current_pull_distance >= 80.0:
				var direction = Vector2.RIGHT.rotated(rotation)
				var speed = current_pull_distance * 10.0
				
				var start_point = global_position
				if is_cannon_loaded:
					speed = 1050.0
					start_point += CANNON_MUZZLE_OFFSET.rotated(rotation)
				
				var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
				update_trajectory(start_point, direction * speed, gravity, is_ghost_loaded, is_cannon_loaded)
			else:
				hide_trajectory()

func _check_weapon_switch():
	if not main_ui or is_switching:
		return
		
	var wants_cannon = (main_ui.current_arrow_type == main_ui.ArrowType.CANNONBALL)
	
	if wants_cannon != is_cannon_loaded:
		is_switching = true
		is_dragging = false
		hide_trajectory()
		_reset_bow_string()
		
		if scale_tween:
			scale_tween.kill()
		scale_tween = create_tween()
		
		scale_tween.tween_property(self, "scale", Vector2.ZERO, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		scale_tween.tween_callback(func():
			is_cannon_loaded = wants_cannon
			if is_cannon_loaded:
				self_modulate.a = 0.0
				bow_string.visible = false
				loaded_arrow.visible = false
				if cannon_sprite:
					cannon_sprite.visible = true
			else:
				self_modulate.a = 1.0
				bow_string.visible = true
				loaded_arrow.visible = false
				if cannon_sprite:
					cannon_sprite.visible = false
		)
		scale_tween.tween_property(self, "scale", base_scale, 0.35).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		scale_tween.tween_callback(func(): is_switching = false)

func _unhandled_input(event):
	if not is_active or is_switching:
		return
		
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT) or event is InputEventScreenTouch:
		if event.pressed:
			is_dragging = true
			drag_start_position = event.position
			
			if main_ui and main_ui.current_arrow_type == main_ui.ArrowType.GHOST:
				is_ghost_loaded = true
				loaded_arrow.texture = tex_ghost_arrow
				loaded_arrow.scale = loaded_arrow_base_scale * 1.6
				loaded_arrow.modulate = Color.WHITE
			else:
				is_ghost_loaded = false
				loaded_arrow.texture = tex_normal_arrow
				loaded_arrow.scale = loaded_arrow_base_scale
				loaded_arrow.modulate = Color.WHITE
				
			if not is_cannon_loaded:
				loaded_arrow.visible = true
				
			target_rotation = rotation
			
		elif is_dragging:
			is_dragging = false
			loaded_arrow.visible = false
			
			if current_pull_distance >= 80.0:
				_shoot_arrow()
			
			hide_trajectory()
			_reset_bow_string()
			current_pull_distance = 0.0

			if not is_cannon_loaded and not is_ghost_loaded:
				if scale_tween:
					scale_tween.kill()
				scale_tween = create_tween()
				scale_tween.tween_property(self, "scale", base_scale * Vector2(0.8, 1.2), 0.05)
				scale_tween.tween_property(self, "scale", base_scale, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _shoot_arrow():
	var arrow = null
	if is_ghost_loaded:
		var ghost_res = load("res://scenes/objects/ghost_arrow.tscn")
		if ghost_res:
			arrow = ghost_res.instantiate()
	elif is_cannon_loaded:
		var cannon_res = load("res://scenes/objects/cannonball.tscn")
		if cannon_res:
			arrow = cannon_res.instantiate()
			
	if not arrow:
		arrow = ARROW_SCENE.instantiate()
		
	var direction = Vector2.RIGHT.rotated(rotation)
	var start_point = global_position
	var speed = current_pull_distance * 10.0
	
	if is_cannon_loaded:
		start_point += CANNON_MUZZLE_OFFSET.rotated(rotation)
		speed = 1050.0
		
	arrow.position = start_point
	arrow.rotation = rotation
	
	if get_tree().current_scene:
		get_tree().current_scene.add_child(arrow)
	
	var velocity = direction * speed
	
	if arrow.has_method("shoot"):
		arrow.shoot(velocity)
	else:
		arrow.linear_velocity = velocity
		if "is_flying" in arrow:
			arrow.is_flying = true
			
	if not is_cannon_loaded and main_ui and main_ui.has_method("play_shoot_sound"):
		main_ui.play_shoot_sound()

	emit_signal("arrow_shot")

func update_trajectory(start_pos: Vector2, initial_velocity: Vector2, gravity: float, is_ghost: bool = false, is_cannon: bool = false):
	trajectory_line.clear_points()
	trajectory_line.add_point(start_pos)

	var current_pos = start_pos
	var current_vel = initial_velocity
	var space_state = get_world_2d().direct_space_state
	var dt = get_physics_process_delta_time() 

	for i in range(trajectory_length):
		var next_vel = current_vel + Vector2(0, gravity) * dt
		var next_pos = current_pos + next_vel * dt 
		
		if not is_ghost:
			if not is_cannon:
				var mud_query = PhysicsRayQueryParameters2D.create(current_pos, next_pos)
				mud_query.collision_mask = 1
				mud_query.collide_with_areas = true
				var mud_result = space_state.intersect_ray(mud_query)
				
				if mud_result and mud_result.collider.get("is_mud"):
					trajectory_line.add_point(mud_result.position)
					break
				
			var query = PhysicsRayQueryParameters2D.create(current_pos, next_pos)
			query.collision_mask = 1
			var result = space_state.intersect_ray(query)
			
			if result:
				trajectory_line.add_point(result.position)
				if result.normal != Vector2.ZERO:
					current_vel = current_vel.bounce(result.normal)
				current_pos = result.position
				continue
				
		trajectory_line.add_point(next_pos)
		current_pos = next_pos
		current_vel = next_vel

func hide_trajectory():
	trajectory_line.clear_points()
