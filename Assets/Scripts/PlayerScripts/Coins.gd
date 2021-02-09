extends Node2D

export(float)var maxSpeed = 100
export(float)var coinAmount = 20
export(float)var acc = 1
onready var speed = 0
onready var player = get_tree().get_root().find_node("Player",true,false)

func _physics_process(delta):
	speed+=acc
	speed=clamp(speed,speed,maxSpeed)
	var dir = (player.global_position - global_position).normalized()
	translate(dir*speed*delta)


func _on_Area2D_area_entered(area):
	if area.get_parent().get_name()=="Player":
		player.AddCoins(coinAmount)
		queue_free()
