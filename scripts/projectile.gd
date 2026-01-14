extends Area2D

@export var speed: float = 1200.0
@export var damage: int = 10
@export var lifetime: float = 2.0

@export var impact_effect_scene: PackedScene
var shooter: Node2D

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
	
	# Raycast loop to handle penetration (e.g. passing through shooter)
	var ray_start = current_pos
	var ray_end = next_pos
	var collision_found = false
	var exclusions = [self]
	if shooter:
		exclusions.append(shooter)
		
	var max_retries = 3 # Prevent infinite loops
	
	while max_retries > 0:
		var query = PhysicsRayQueryParameters2D.create(ray_start, ray_end)
		query.collide_with_bodies = true
		query.collide_with_areas = true
		query.hit_from_inside = true
		query.exclude = exclusions
		
		var result = space_state.intersect_ray(query)
		
		if result:
			var body = result.collider
			print("RayCast Hit: ", body.name, " Group: ", body.get_groups())
			
			if body.is_in_group("player") or body == shooter:
				# Hit player/shooter -> Add to exclusions and retry from same spot
				print("Hit Player/Shooter, retrying exclusion...") # DEBUG
				exclusions.append(body)
				max_retries -= 1
				continue
			else:
				# Hit valid target
				position = result.position
				_on_hit(body)
				collision_found = true
				break
		else:
			# No hit
			break
			
	if not collision_found:
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
