extends Area2D

@export var speed: float = 600.0
var is_deflected: bool = false
var deflect_velocity: Vector2 = Vector2.ZERO

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	get_tree().create_timer(3.0).timeout.connect(queue_free)

func _process(delta):
	if is_deflected:
		deflect_velocity.y += 1500.0 * delta
		position += deflect_velocity * delta
		rotation += 20.0 * delta
	else:
		position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _on_body_entered(body):
	if body.has_method("pop"):
		if body.has_node("IceBarrier"):
			_deflect_spike()
		else:
			body.pop()
			queue_free()

func _on_area_entered(area):
	if area.has_method("pop"):
		if area.has_node("IceBarrier"):
			_deflect_spike()
		else:
			area.pop()
			queue_free()

func _deflect_spike():
	if not is_deflected:
		is_deflected = true
		var current_dir = Vector2.RIGHT.rotated(rotation)
		deflect_velocity = Vector2(-current_dir.x * 300.0, -400.0)
	else:
		deflect_velocity.x *= -1.0
		deflect_velocity.y = -300.0
	
	var main_scene = get_tree().current_scene
	if main_scene.has_node("UI") and main_scene.get_node("UI").has_method("play_ice_sound"):
		main_scene.get_node("UI").play_ice_sound()
