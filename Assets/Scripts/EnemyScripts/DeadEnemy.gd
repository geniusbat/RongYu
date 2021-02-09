extends KinematicBody2D

export(float)var speed = 80
export(bool) var outside = false
export(bool) var moving = true
export(Vector2) var dir = Vector2.ZERO

func _physics_process(_delta):
	if moving:
		var _a=move_and_slide(dir*speed)
	elif outside:
		var _a=move_and_slide(Vector2.DOWN*speed)

func Fall():
	outside = true
	moving = false
	#Assign proper z index depending if it is above or below arena
	if has_node("CollisionShape2D") and global_position.y < 0:
#		z_as_relative=false
#		z_index=-40
		$Sprite.z_as_relative=false
		$Sprite.z_index=-40
	

func MovingTimerTimeout():
	#Leave only the sprite
	if moving:
#		var sprite = $Sprite
#		remove_child(sprite)
#		get_parent().call_deferred("add_child",sprite)
#		sprite.global_position=global_position
		set_physics_process(false)
		$CollisionShape2D.queue_free()
		$MovingTimer.queue_free()
