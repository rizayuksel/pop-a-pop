extends RigidBody2D

var is_stuck = false
var flight_rotation: float = 0.0

func _ready():
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	collision_mask = 1

func _process(_delta):
	if is_stuck:
		return
		
	if linear_velocity.length() > 5.0:
		flight_rotation = linear_velocity.angle()
		rotation = flight_rotation

func split_arrow():
	if is_stuck:
		return
		
	var main_scene = get_tree().current_scene
	var current_vel = linear_velocity
	var arrow_scene = load(scene_file_path)
	
	var angles = [-18.0, 18.0]
	
	for angle in angles:
		var new_arrow = arrow_scene.instantiate()
		new_arrow.global_position = global_position
		new_arrow.linear_velocity = current_vel.rotated(deg_to_rad(angle))
		new_arrow.rotation = new_arrow.linear_velocity.angle()
		main_scene.call_deferred("add_child", new_arrow)

func stick():
	is_stuck = true
	set_process(false)
	rotation = flight_rotation 
	set_deferred("freeze", true)

	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
