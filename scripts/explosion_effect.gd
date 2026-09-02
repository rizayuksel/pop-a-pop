extends Node2D

func _ready():
	print("EXPLOSION SCENE SPAWNED AT: ", global_position)
	
	if has_node("CPUParticles2D"):
		print("PARTICLES NODE FOUND!")
		$CPUParticles2D.restart()
		$CPUParticles2D.emitting = true
	else:
		print("ERROR: PARTICLES NODE NOT FOUND!")
		
	await get_tree().create_timer(0.7).timeout
	queue_free()
