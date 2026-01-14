extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite = $Sprite2D

func _ready():
	add_to_group("player")
	_setup_inputs()

func _setup_inputs():
	# Failsafe: Ensure actions exist even if project settings fail
	var actions = {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"jump": [KEY_SPACE, KEY_UP],
		"fire": [MOUSE_BUTTON_LEFT]
	}
	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			for key in actions[action]:
				var event
				if typeof(key) == TYPE_INT and key < 10:
					event = InputEventMouseButton.new()
					event.button_index = key
				else:
					event = InputEventKey.new()
					event.keycode = key
				InputMap.action_add_event(action, event)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	
	# Fallback: Check raw keys if InputMap fails
	if direction == 0:
		if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
			direction -= 1
		if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
			direction += 1
			
	if direction != 0:
		print("Moving! Direction: ", direction) # DEBUG: Confirm input reception
		velocity.x = direction * SPEED
		# Flip sprite based on direction
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Handle Shooting
	if Input.is_action_pressed("fire") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Assuming a child node named "Weapon" exists
		if has_node("Weapon"):
			$Weapon.shoot()

	move_and_slide()
	if direction != 0:
		print("Pos: ", global_position, " Vel: ", velocity)
