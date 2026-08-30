extends Node2D

const ARROW_SCENE = preload("res://scenes/arrow.tscn")
const MAX_DRAG_LENGTH = 150.0

var is_dragging = false
var drag_start_position = Vector2.ZERO

@onready var rubber_band = $RubberBand
@onready var bow = $Bow
@onready var loaded_arrow = $Bow/LoadedArrow

func _unhandled_input(event):
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
			shoot_arrow(drag_start_position, drag_end_position)

func _process(_delta):
	if is_dragging:
		var current_mouse_pos = get_global_mouse_position()
		var drag_vector = drag_start_position - current_mouse_pos
		
		drag_vector = drag_vector.limit_length(MAX_DRAG_LENGTH)
		
		bow.look_at(bow.position + drag_vector)
		
		var pull_distance = drag_vector.length()
		var draw_point = bow.position - drag_vector
		
		rubber_band.clear_points()
		rubber_band.add_point(bow.position)
		rubber_band.add_point(draw_point)
		
		loaded_arrow.position = Vector2(-pull_distance, 0)

func shoot_arrow(start_pos, end_pos):
	var drag_vector = start_pos - end_pos
	
	drag_vector = drag_vector.limit_length(MAX_DRAG_LENGTH)
	var pull_distance = drag_vector.length()
	
	if pull_distance < 80.0:
		print("Shot CANCELLED! Pull distance too short: ", pull_distance)
		return
		
	var arrow = ARROW_SCENE.instantiate()
	arrow.position = bow.position
	arrow.rotation = drag_vector.angle()
	
	get_tree().current_scene.add_child(arrow)
	
	var direction = drag_vector.normalized()
	var speed = pull_distance * 10.0
	
	arrow.apply_central_impulse(direction * speed)
	
	print("Arrow FIRED! Pull distance: ", pull_distance, " | Applied Speed: ", speed)
