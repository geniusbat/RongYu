extends Node2D

onready var healthIcon = preload("res://Assets/Sprites/shieldIcon.png")

func MaxHealthChanged(maxHealth):
	if get_child_count() < maxHealth:
		var goal = maxHealth
		var i = get_child_count()+1
		while i <= goal:
			var ins = Sprite.new()
			add_child(ins)
			ins.texture=healthIcon
			ins.position=Vector2(23,47*i)
			i+=1
	elif get_child_count()!=maxHealth:
		var goal = maxHealth
		var i = get_child_count()
		while i >= goal:
			get_child(i-1).queue_free()
			i-=1

#Call this whenever health changes so you can show correct amount of health
func HealthChanged(health):
	for el in get_children():
		#Show current health
		if el.get_index<=health:
			el.visible=true
		else:
			el.visible=false
