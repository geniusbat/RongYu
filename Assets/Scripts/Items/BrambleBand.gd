extends Node2D

var itemInfo : ItemRes = preload("res://Assets/Misc/ItemRes/BrambleBand.tres")
onready var player = get_node("../..")
onready var rng = RandomNumberGenerator.new()

func _ready():
	var _a = player.connect("playerDamaged",self,"PlayerDamaged")

func PlayerDamaged():
	var num = 30 + player.luck
	#Max probabilty is 95
	num = clamp(num,num,95)
	if rng.randi_range(0,100)<num:
		#Get nearest enemy to player
		var enemy
		var distance
		var playerPos = player.global_position
		for i in get_tree().get_nodes_in_group("Enemies"):
			if enemy==null:
				enemy = i
				distance = playerPos.distance_to(enemy.global_position)
			else:
				if playerPos.distance_to(i.global_position) < distance:
					distance = playerPos.distance_to(i.global_position)
					enemy = i
		enemy.DamageWithoutKnockbackAndTimer(1)
