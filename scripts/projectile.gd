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
	position += transform.x * speed * delta

@export var impact_effect_scene: PackedScene

func _on_body_entered(body):
	# Ignore collision with the shooter (if setup correctly via layers/masks, but safe guard here)
	if body.is_in_group("player"): 
		return

	# Start Impact Effect
	if impact_effect_scene:
		var impact = impact_effect_scene.instantiate()
		impact.global_position = global_position
		get_tree().root.add_child(impact)
		impact.emitting = true

	print("Hit: ", body.name)
	
	# TODO: Apply Damage if body has "take_damage" method
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	queue_free()
