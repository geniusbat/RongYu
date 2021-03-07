extends Node

var itemInfo : ItemRes = preload("res://Assets/Misc/ItemRes/Alcohol.tres")
onready var player = get_node("../..")

func ItemUse():
	if player.health!=player.maxHealth:
		print("SS")
		player.health=player.health+1
		player.HealthChanged()
		player.get_node("GUI/Inventory").DeleteItem(get_index())
