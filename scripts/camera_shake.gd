extends Camera2D

# Usage: Call shake(intensity, duration)
var shake_amount: float = 0.0
var default_offset: Vector2 = Vector2.ZERO

func _ready():
	default_offset = offset
	# Ensure this camera is current or set elsewhere
	make_current()

func _process(delta):
	if shake_amount > 0:
		offset = default_offset + Vector2(randf_range(-1.0, 1.0) * shake_amount, randf_range(-1.0, 1.0) * shake_amount)
		shake_amount = lerp(shake_amount, 0.0, 5.0 * delta) # Decay shake
		if shake_amount < 1.0:
			shake_amount = 0.0
			offset = default_offset

func shake(intensity: float, _duration: float = 0.2):
	# Simple implementation: just set intensity, let _process decay it
	shake_amount = intensity
