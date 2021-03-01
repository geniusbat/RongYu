extends Node

var itemInfo : ItemRes = preload("res://Assets/Misc/ItemRes/JadeArmour.tres")
onready var player = get_node("../..")
export(int)var armorRating = 10

func ItemWasDeleted():
	player.bonusArmour-=armorRating

func ItemWasAdded():
	player.bonusArmour+=armorRating
