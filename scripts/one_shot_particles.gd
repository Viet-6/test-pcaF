extends CPUParticles2D

func _ready():
	z_index = 100
	emitting = true
	finished.connect(queue_free)
