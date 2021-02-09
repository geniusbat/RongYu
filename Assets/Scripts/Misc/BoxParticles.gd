extends Node2D

func _ready():
	$Particles2D.emitting=true
	yield(get_tree().create_timer(0.8),"timeout")
	queue_free()
