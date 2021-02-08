extends Node2D

export(float)var speed = 100
export(float)var coinAmount = 20
onready var player = get_tree().get_root().get_child(0).find_node("Player",true,false)

func _physics_process(delta):
	var dir = (player.global_position - global_position).normalized()
	translate(dir*speed*delta)


func _on_Area2D_area_entered(area):
	if area.get_parent().get_name()=="Player":
		player.AddCoins(coinAmount)
		queue_free()
