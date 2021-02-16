extends KinematicBody2D

var direction : Vector2
export(float) var speed = 100
onready var bounced = false

func _physics_process(delta):
	look_at(position+direction)
	var a = move_and_collide(direction*speed*delta)
	#Delete if it hits a wall or something
	if a!=null:
		queue_free()

func Bounce(fromPos:Vector2):
	if !bounced:
		bounced=true
		direction=(global_position-fromPos).normalized()

func _on_HitboxArea_area_entered(area):
	if area.get_parent().get_name()=="Player":
		area.get_parent().Damage(1,(area.get_parent().global_position-global_position).normalized())
		queue_free()


func _on_HitboxArea_area_exited(area):
	_on_HitboxArea_area_entered(area)
