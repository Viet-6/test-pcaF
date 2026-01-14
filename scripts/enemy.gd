extends CharacterBody2D

@export var max_health: int = 30
var current_health: int

func _ready():
	current_health = max_health
	add_to_group("enemies")

const SPEED = 100.0
const GRAVITY = 980.0
const PATROL_TIME = 2.0
const IDLE_TIME = 1.0

enum State { IDLE, PATROL, ATTACK }
var current_state = State.PATROL
var direction = 1 # 1 = Right, -1 = Left
var state_timer = 0.0

@onready var vision_ray = $VisionRay
@onready var floor_ray = $FloorCheck
@onready var weapon = $Weapon # Assume we add a weapon node

func _physics_process(delta):
	# Apply Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# State Logic
	match current_state:
		State.IDLE:
			velocity.x = 0
			_process_idle(delta)
		State.PATROL:
			_process_patrol(delta)
		State.ATTACK:
			velocity.x = 0
			_process_attack(delta)
			
	move_and_slide()

func _process_idle(delta):
	state_timer -= delta
	if state_timer <= 0:
		set_state(State.PATROL)
		# Flip direction optionally
		if randf() > 0.5:
			flip()

func _process_patrol(delta):
	# Move
	velocity.x = direction * SPEED
	
	# Check for cliffs or walls
	if is_on_wall() or not floor_ray.is_colliding():
		flip()
		
	# Check for player (Simple Vision)
	if vision_ray.is_colliding():
		var collider = vision_ray.get_collider()
		if collider and collider.is_in_group("player"):
			set_state(State.ATTACK)
			
	# Optional: Periodically stop
	state_timer -= delta
	if state_timer <= 0:
		set_state(State.IDLE)

func _process_attack(delta):
	# Face the player (RayCast logic handles this normally if we keep tracking)
	# Check if player still visible
	if not vision_ray.is_colliding():
		# Lost sight? Go back to patrol/idle
		set_state(State.IDLE)
		return
		
	var collider = vision_ray.get_collider()
	if not collider or not collider.is_in_group("player"):
		set_state(State.IDLE)
		return
		
	# Shoot!
	if weapon and weapon.has_method("shoot"):
		weapon.shoot() # Weapon script handles fire rate/cooldown internaly

func set_state(new_state):
	current_state = new_state
	match new_state:
		State.IDLE:
			state_timer = IDLE_TIME
		State.PATROL:
			state_timer = PATROL_TIME
		State.ATTACK:
			state_timer = 5.0 # Max attack time before re-evaluating

func flip():
	direction *= -1
	scale.x = -1 # Flip the sprite AND the RayCasts attached to it


func take_damage(amount: int):
	current_health -= amount
	print(name, " took ", amount, " damage. Health: ", current_health)
	
	# Flash red effect
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate", Color.RED, 0.05)
	tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.05)
	
	if current_health <= 0:
		die()

func die():
	print(name, " died.")
	# TODO: Spawn explosion or loot
	queue_free()
