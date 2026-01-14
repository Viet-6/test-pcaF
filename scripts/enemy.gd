extends CharacterBody2D

@export var max_health: int = 30
var current_health: int

func _ready():
	current_health = max_health
	add_to_group("enemies")

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
