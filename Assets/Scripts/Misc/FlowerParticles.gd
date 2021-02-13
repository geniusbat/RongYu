extends Particles2D

func _ready():
	emitting=true
	$Particles2D.emitting=true

func _on_Timer_timeout():
	queue_free()
