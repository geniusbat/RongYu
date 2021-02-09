extends Area2D

onready var deadEnemy = preload("res://Objects/Enemies/DeadEnemy.tscn")
onready var player = get_parent().find_node("Player",true,false)

#Kill body that has exited
func _on_OutsideArena_body_exited(body):
	#Is player
	if body.get_name()=="Player":
		get_tree().quit()
	elif body.has_method("Fall"):
		body.call_deferred("Fall")
	elif body.is_in_group("Enemies"):
		if body.state!=4:
			if player!=null:
				player.emit_signal("enemyKilled",body)
			body.DieByFalling()
