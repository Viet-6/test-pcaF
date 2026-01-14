extends CharacterBody2D

@export var max_health: int = 30
var current_health: int

func _ready():
	current_health = max_health
	add_to_group("enemies")
	
	# Force create collision shape to ensure it exists (Scene file paranoia)
	var shape = RectangleShape2D.new()
	shape.size = Vector2(100, 200)
	
	var col = CollisionShape2D.new()
	col.shape = shape
	col.debug_color = Color(1, 0, 0, 0.5)
	add_child(col)
	print("Enemy Initialized with Procedural Collision Shape")

func _physics_process(delta):
	# Add gravity so it sits on floor properly
	if not is_on_floor():
		velocity.y += 980.0 * delta
	move_and_slide()


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
