extends Area2D

@export var speed: float = 1200.0
@export var damage: int = 10
@export var lifetime: float = 2.0

func _ready():
	# Auto-destroy after lifetime to prevent memory leaks
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)
	
	# Connect collision signal
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	var space_state = get_world_2d().direct_space_state
	var current_pos = global_position
	var next_pos = current_pos + transform.x * speed * delta
	
	# Raycast from current to next position to detect hits between frames (prevents tunneling)
	var query = PhysicsRayQueryParameters2D.create(current_pos, next_pos)
	query.collide_with_bodies = true
	query.collide_with_areas = true
	# Exclude shooter (if we had a reference) and self
	query.exclude = [self] 
	
	var result = space_state.intersect_ray(query)
	
	if result:
		# Hit something!
		var body = result.collider
		
		# Manual filtering (since we can't easily exclude group via query without RID)
		if body.is_in_group("player"):
			position = next_pos # Pass through player
		else:
			position = result.position # Move to hit point
			_on_hit(body)
	else:
		position = next_pos

func _on_hit(body):
	# Start Impact Effect
	if impact_effect_scene:
		var impact = impact_effect_scene.instantiate()
		impact.global_position = global_position
		get_tree().root.add_child(impact)
		impact.emitting = true

	print("Hit: ", body.name)
	
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	queue_free()

func _on_body_entered(body):
	# Keep Area2D check just in case, but rely mainly on RayCast
	if body.is_in_group("player"): 
		return
	_on_hit(body)
