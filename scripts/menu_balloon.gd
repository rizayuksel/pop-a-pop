extends Area2D

@onready var sprite = $Sprite2D
@onready var audio = $AudioStreamPlayer2D

var popped_texture = preload("res://assets/textures/PoppedBalloon.png")
var is_popped = false
var speed = 90.0
var fall_speed = 0.0

func _ready():
	input_pickable = true

func _process(delta):
	if not is_popped:
		position.y -= speed * delta

		if position.y < -50:
			queue_free()
	else:
		fall_speed += 200.0 * delta
		position.y += fall_speed * delta

		var screen_height = get_viewport_rect().size.y
		if position.y > screen_height + 100:
			queue_free()

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_popped:
			var mouse_pos = get_global_mouse_position()
			if global_position.distance_to(mouse_pos) < 35.0:
				pop_balloon()

func pop_balloon():
	is_popped = true
	speed = 0.0
	
	if audio.stream:
		audio.play()
	
	if popped_texture:
		sprite.texture = popped_texture
