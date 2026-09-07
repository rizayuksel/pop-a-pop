extends Control

const TOTAL_LEVELS = 20
const LEVELS_PER_PAGE = 10
const COLUMNS = 2

var current_page = 0
var total_pages = 0
var pages: Array = []
var touch_start_pos = Vector2.ZERO

@onready var pages_container = $PagesContainer
@onready var left_btn = $LeftButton
@onready var right_btn = $RightButton
@onready var home_btn = $HomeButton

# Load the level button scene
var level_btn_scene = preload("res://scenes/level_button.tscn")

func _ready():
	left_btn.pressed.connect(prev_page)
	right_btn.pressed.connect(next_page)
	home_btn.pressed.connect(_on_home_pressed)
	
	total_pages = ceil(float(TOTAL_LEVELS) / LEVELS_PER_PAGE)
	generate_pages()
	auto_focus_page()
	update_ui()

func generate_pages():
	var highest_unlocked = 1
	
	for p in range(total_pages):
		var grid = GridContainer.new()
		grid.columns = COLUMNS
		grid.add_theme_constant_override("h_separation", 30)
		grid.add_theme_constant_override("v_separation", 30)
		grid.visible = false
		pages_container.add_child(grid)
		pages.append(grid)
		
		for i in range(LEVELS_PER_PAGE):
			var level_num = (p * LEVELS_PER_PAGE) + i + 1
			if level_num > TOTAL_LEVELS:
				break
				
			var btn = level_btn_scene.instantiate()
			
			# Add to scene tree first so @onready variables are initialized
			grid.add_child(btn)
			
			# Lock logic: Level 1 is always unlocked, others depend on previous level stars
			var is_unlocked = (level_num == 1)
			if level_num > 1:
				var prev_stars = SaveManager.get_level_stars("level_" + str(level_num - 1))
				is_unlocked = (prev_stars > 0)
				if is_unlocked:
					highest_unlocked = level_num
			
			var stars = SaveManager.get_level_stars("level_" + str(level_num))
			
			# Setup can now run safely
			btn.setup(level_num, is_unlocked, stars)
			
			if is_unlocked:
				btn.pressed.connect(_on_level_pressed.bind(level_num))

func auto_focus_page():
	# Find the page with the highest unlocked level
	var highest_unlocked = 1
	for i in range(1, TOTAL_LEVELS + 1):
		if i > 1 and SaveManager.get_level_stars("level_" + str(i - 1)) > 0:
			highest_unlocked = i
	
	current_page = floor((highest_unlocked - 1) / LEVELS_PER_PAGE)

func update_ui():
	for i in range(pages.size()):
		pages[i].visible = (i == current_page)
		
	left_btn.visible = (current_page > 0)
	right_btn.visible = (current_page < total_pages - 1)

func next_page():
	if current_page < total_pages - 1:
		current_page += 1
		update_ui()

func prev_page():
	if current_page > 0:
		current_page -= 1
		update_ui()

# Detect swipe gestures for mobile or mouse
func _input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			touch_start_pos = event.position
		else:
			var swipe_dist = event.position.x - touch_start_pos.x
			# Change page if swiped more than 100 pixels
			if swipe_dist > 100:
				prev_page()
			elif swipe_dist < -100:
				next_page()

func _on_level_pressed(level_num: int):
	get_tree().change_scene_to_file("res://scenes/level_" + str(level_num) + ".tscn")

func _on_home_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
