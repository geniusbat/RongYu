extends Node2D

var followTarget : bool
var target 

func _ready():
	$Particles2D.emitting=true
	$Particles2D2.emitting=true
	followTarget = false
	target=null

func _process(_delta):
	if followTarget:
		if target!=null:
			global_position=target.global_position

func _on_Timer_timeout():
	queue_free()
