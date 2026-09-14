extends Area2D

@export var speed: float = 600.0

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Self-destruct after 3 seconds
	get_tree().create_timer(3.0).timeout.connect(queue_free)

func _process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _on_body_entered(body):
	print("Spike hit a Body: ", body.name)
	if body.has_method("pop"):
		body.pop()
		queue_free()

func _on_area_entered(area):
	print("Spike hit an Area: ", area.name)
	if area.has_method("pop"):
		print("Pop method found, destroying balloon!")
		area.pop()
		queue_free()
	else:
		print("Pop method NOT found in: ", area.name)
