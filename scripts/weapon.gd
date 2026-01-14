extends Node2D

class_name Weapon

@export var fire_rate: float = 0.1
@export var damage: int = 10
@export var projectile_speed: float = 1000.0

var can_fire: bool = true
@onready var muzzle = $Muzzle

func _process(_delta):
	look_at(get_global_mouse_position())

@export var projectile_scene: PackedScene

func shoot():
	if not can_fire:
		return
	
	print("Bang!")
	
@export var muzzle_flash_scene: PackedScene

	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = muzzle.global_position
		projectile.global_rotation = global_rotation
		get_tree().root.add_child(projectile)
	
	# Muzzle Flash
	if muzzle_flash_scene:
		var flash = muzzle_flash_scene.instantiate()
		flash.global_position = muzzle.global_position
		flash.global_rotation = global_rotation
		get_tree().root.add_child(flash)
	
	# Screen Shake
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("shake"):
		camera.shake(5.0) # Intensity
	
	can_fire = false
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true
