extends Node2D

@export var building_color: Color = Color(0.05, 0.05, 0.1)
@export var window_color: Color = Color(0.0, 0.8, 1.0, 0.8) # Neon Cyan
@export var density: int = 15

func _ready():
	_generate_skyline()

func _generate_skyline():
	var viewport_size = get_viewport_rect().size
	var width = viewport_size.x * 2 # Make it wider for scrolling
	
	for i in range(density):
		var building = ColorRect.new()
		var b_width = randf_range(50, 150)
		var b_height = randf_range(100, 400)
		
		building.size = Vector2(b_width, b_height)
		building.position = Vector2(randf_range(0, width), viewport_size.y - b_height)
		building.color = building_color
		
		add_child(building)
		
		# Add random "neon" windows
		if randf() > 0.5:
			_add_windows(building)

func _add_windows(building):
	var rows = randi_range(2, 5)
	var cols = randi_range(2, 4)
	var win_w = 4
	var win_h = 4
	var gap = 10
	
	for r in range(rows):
		for c in range(cols):
			if randf() > 0.3: # Randomly skip windows
				continue
			var win = ColorRect.new()
			win.size = Vector2(win_w, win_h)
			win.position = Vector2(10 + c * (win_w + gap), 10 + r * (win_h + gap))
			win.color = window_color
			building.add_child(win)
