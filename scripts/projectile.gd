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
	
	# Raycast using Collision Mask 5 (Layer 1:Floor + Layer 3:Enemy)
	# This implicitly ignores Layer 2 (Player), solving the self-hit issue perfectly.
	var query = PhysicsRayQueryParameters2D.create(current_pos, next_pos)
	query.collide_with_bodies = true
	query.collide_with_areas = false # Projectiles shouldn't hit other Areas (like triggers or bullets)
	query.collision_mask = 5 # 1 (Floor) + 4 (Enemy)
	query.hit_from_inside = true
	
	var result = space_state.intersect_ray(query)
	
	if result:
		# Hit something valid (Player is ignored by mask)
		var body = result.collider
		print("Hit Object: ", body.name, " | Layer: ", body.collision_layer)
		position = result.position
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
