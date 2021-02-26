extends Area2D

onready var deadEnemy = preload("res://Objects/Enemies/DeadEnemy.tscn")
onready var player = get_parent().find_node("Player",true,false)
onready var count = false

#Kill body that has exited
func _on_OutsideArena_body_exited(body):
	if !count:
		return
	#Is player
	if body.get_name()=="Player":
#		get_tree().quit()
		pass
	elif body.has_method("Fall"):
		body.call_deferred("Fall")
	elif body.is_in_group("Enemies"):
		if body.state!=4:
			if player!=null:
				player.emit_signal("enemyKilled",body)
			body.DieByFalling()
#Keep this as it is, idk why but enemies would fall when spawning
func _on_Timer_timeout():
	count=true
