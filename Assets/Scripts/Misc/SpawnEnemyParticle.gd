extends Node2D

func _ready():
	$Particles2D.emitting=true
	$Particles2D2.emitting=true


func _on_Timer_timeout():
	queue_free()
