extends Node

func _ready():
	setup_inputs()

func setup_inputs():
	# Define actions and their defaults
	var actions = {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"jump": [KEY_SPACE, KEY_UP],
		"fire": [MOUSE_BUTTON_LEFT]
	}
	
	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		
		# Clear existing to ensure clean state
		InputMap.action_erase_events(action)
		
		# Add events
		for key in actions[action]:
			var event
			if typeof(key) == TYPE_INT and key < 10: # Rough check for Mouse Button enum
				event = InputEventMouseButton.new()
				event.button_index = key
			else:
				event = InputEventKey.new()
				event.keycode = key
			InputMap.action_add_event(action, event)
	
	print("Inputs initialized via script.")
