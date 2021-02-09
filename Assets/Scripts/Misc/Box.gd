extends KinematicBody2D

export(float) var speed = 100
export(int) var health = 2

var dir : Vector2
onready var knockbackTimer = $KnockbackTimer
onready var isKnocked = false
onready var fallen = false
onready var particles = preload("res://Objects/Misc/Particles/BoxParticles.tscn")

func _physics_process(_delta):
	if isKnocked:
		var _a = move_and_slide(dir*speed)
	elif fallen:
		var _a = move_and_slide(Vector2.DOWN*speed)

func Damage(damage,direction):
	dir = direction
	if !isKnocked:
		health -= damage
		if health>0:
			Knockback(direction)
		else:
			var ins = particles.instance()
			ins.global_position=global_position
			get_parent().add_child(ins)
			queue_free()

func Fall():
	fallen = true
	if has_node("CollisionShape2D") and global_position.y < 0:
#		z_as_relative=false
#		z_index=-40
		$Sprite.z_as_relative=false
		$Sprite.z_index=-40

func Knockback(_direction):
	if !isKnocked:
		isKnocked=true
		knockbackTimer.start()


func _on_KnockbackTimer_timeout():
	isKnocked=false
