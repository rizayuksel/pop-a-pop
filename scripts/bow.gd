extends Sprite2D

signal arrow_shot

const ARROW_SCENE = preload("res://scenes/arrow.tscn")
const MAX_DRAG_LENGTH = 150.0

var is_dragging = false
var drag_start_position = Vector2.ZERO
var is_active = true
var trajectory_length: int = 30
var time_step: float = 0.05

@onready var rubber_band = $"../RubberBand"
@onready var loaded_arrow = $LoadedArrow
@onready var trajectory_line = $Line2D

func _ready():
	trajectory_line.top_level = true
	trajectory_line.global_position = Vector2.ZERO
	hide_trajectory()

func _unhandled_input(event):
	if not is_active:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_start_position = get_global_mouse_position()
			loaded_arrow.visible = true
		elif is_dragging:
			is_dragging = false
			loaded_arrow.visible = false
			rubber_band.clear_points()
			var drag_end_position = get_global_mouse_position()
			_shoot_arrow(drag_start_position, drag_end_position)
			hide_trajectory()

func _process(_delta):
	if is_dragging and is_active:
		var current_mouse_pos = get_global_mouse_position()
		var drag_vector = drag_start_position - current_mouse_pos
		
		drag_vector = drag_vector.limit_length(MAX_DRAG_LENGTH)
		look_at(position + drag_vector)
		
		var pull_distance = drag_vector.length()
		var draw_point = position - drag_vector
		
		rubber_band.clear_points()
		rubber_band.add_point(position)
		rubber_band.add_point(draw_point)
		
		loaded_arrow.position = Vector2(-pull_distance, 0)
		
		if pull_distance >= 80.0:
			var direction = drag_vector.normalized()
			var speed = pull_distance * 10.0
			var initial_velocity = direction * speed
			var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
			
			update_trajectory(global_position, initial_velocity, gravity)
		else:
			hide_trajectory()

func _shoot_arrow(start_pos, end_pos):
	var drag_vector = start_pos - end_pos
	drag_vector = drag_vector.limit_length(MAX_DRAG_LENGTH)
	var pull_distance = drag_vector.length()
	
	if pull_distance < 80.0:
		return
		
	var arrow = ARROW_SCENE.instantiate()
	arrow.position = position
	arrow.rotation = drag_vector.angle()
	get_tree().current_scene.add_child(arrow)
	
	var direction = drag_vector.normalized()
	var speed = pull_distance * 10.0
	arrow.apply_central_impulse(direction * speed)
	
	emit_signal("arrow_shot")

func update_trajectory(start_pos: Vector2, initial_velocity: Vector2, gravity: float):
	trajectory_line.clear_points()
	
	for i in range(trajectory_length):
		var t = i * time_step
		var current_point = start_pos + (initial_velocity * t) + (0.5 * Vector2(0, gravity) * t * t)
		trajectory_line.add_point(current_point)

func hide_trajectory():
	trajectory_line.clear_points()
