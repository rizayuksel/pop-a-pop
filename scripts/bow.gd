extends Sprite2D

signal arrow_shot

const ARROW_SCENE = preload("res://scenes/objects/arrow.tscn")
const MAX_DRAG_LENGTH = 150.0
const SMOOTH_SPEED = 25.0

var is_dragging = false
var drag_start_position = Vector2.ZERO
var is_active = true
var base_scale = Vector2.ONE

var current_pull_distance = 0.0
var target_rotation = 0.0

@onready var bow_string = $BowString
@onready var loaded_arrow = $LoadedArrow
@onready var trajectory_line = $Line2D
@export var trajectory_length: int = 80

var top_tip = Vector2(-20, -130) 
var bottom_tip = Vector2(-20, 120)

func _ready():
	base_scale = scale
	trajectory_line.top_level = true
	trajectory_line.global_position = Vector2.ZERO
	hide_trajectory()
	
	_reset_bow_string()

func _reset_bow_string():
	bow_string.clear_points()
	bow_string.add_point(top_tip)
	bow_string.add_point(Vector2(-20, 0))
	bow_string.add_point(bottom_tip)

func _unhandled_input(event):
	if not is_active:
		return
		
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT) or event is InputEventScreenTouch:
		if event.pressed:
			is_dragging = true
			drag_start_position = event.position
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

			var tween = get_tree().create_tween()
			tween.tween_property(self, "scale", base_scale * Vector2(0.8, 1.2), 0.05)
			tween.tween_property(self, "scale", base_scale, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _process(delta):
	if is_dragging and is_active:
		var current_pos = get_viewport().get_mouse_position()
		var drag_vector = drag_start_position - current_pos
		
		if drag_vector.length() > 5.0:
			drag_vector = drag_vector.limit_length(MAX_DRAG_LENGTH)
			target_rotation = drag_vector.angle()
			
			var target_pull = drag_vector.length()
			
			rotation = lerp_angle(rotation, target_rotation, SMOOTH_SPEED * delta)
			current_pull_distance = lerp(current_pull_distance, target_pull, SMOOTH_SPEED * delta)
			
			bow_string.set_point_position(1, Vector2(-current_pull_distance, 0))
			loaded_arrow.position = Vector2(-current_pull_distance, 0)
			
			if current_pull_distance >= 80.0:
				var direction = Vector2.RIGHT.rotated(rotation)
				var speed = current_pull_distance * 10.0
				var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
				
				update_trajectory(global_position, direction * speed, gravity)
			else:
				hide_trajectory()

func _shoot_arrow():
	var arrow = ARROW_SCENE.instantiate()
	arrow.position = global_position 
	arrow.rotation = rotation
	get_tree().current_scene.add_child(arrow)
	
	var direction = Vector2.RIGHT.rotated(rotation)
	var speed = current_pull_distance * 10.0
	arrow.linear_velocity = direction * speed
	
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI") and main_scene.get_node("UI").has_method("play_shoot_sound"):
		main_scene.get_node("UI").play_shoot_sound()
	
	emit_signal("arrow_shot")

func update_trajectory(start_pos: Vector2, initial_velocity: Vector2, gravity: float):
	trajectory_line.clear_points()
	trajectory_line.add_point(start_pos)

	var current_pos = start_pos
	var current_vel = initial_velocity
	var space_state = get_world_2d().direct_space_state
	var dt = get_physics_process_delta_time() 

	for i in range(trajectory_length):
		var next_vel = current_vel + Vector2(0, gravity) * dt
		var next_pos = current_pos + next_vel * dt 
		
		var query = PhysicsRayQueryParameters2D.create(current_pos, next_pos)
		query.collision_mask = 1
		var result = space_state.intersect_ray(query)
		
		if result:
			trajectory_line.add_point(result.position)
			current_vel = current_vel.bounce(result.normal)
			current_pos = result.position
		else:
			trajectory_line.add_point(next_pos)
			current_pos = next_pos
			current_vel = next_vel

func hide_trajectory():
	trajectory_line.clear_points()
