extends Node2D

class_name Weapon

@export var fire_rate: float = 0.1
@export var damage: int = 10
@export var projectile_speed: float = 1000.0

var can_fire: bool = true
@onready var muzzle = $Muzzle

func _process(_delta):
	look_at(get_global_mouse_position())

func shoot():
	if not can_fire:
		return
	
	print("Bang!")
	# TODO: Spawn projectile or RayCast logic
	# TODO: Muzzle Flash
	# TODO: Screen Shake
	
	can_fire = false
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true
