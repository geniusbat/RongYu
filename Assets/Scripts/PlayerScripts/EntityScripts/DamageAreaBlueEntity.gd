extends Area2D

var enemies : Array

func _ready():
	enemies=[]
	$Particles2D.emitting=true
	$Particles2D2.emitting=true
#	$Particles2D3.emitting=true
	$Particles2D4.emitting=true

func _process(_delta):
	var areas = get_overlapping_areas()
	for el in areas:
		if el.get_parent().has_method("Damage"):
			var parent = el.get_parent()
			if !enemies.has(parent):
				enemies.append(parent)
				parent.Damage(1,(parent.global_position-global_position).normalized())
	

func _on_Timer_timeout():
	queue_free()
