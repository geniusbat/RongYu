extends Node

var itemInfo : ItemRes = preload("res://Assets/Misc/ItemRes/JadeArmour.tres")
onready var player = get_node("../..")
export(int)var armorRating = 99

func ItemWasDeleted():
	player.armour-=armorRating

func ItemWasAdded():
	player.armour+=armorRating
