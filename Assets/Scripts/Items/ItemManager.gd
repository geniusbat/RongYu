extends Node

var items : Dictionary
#Items is a dictionary of <itemName,ItemResource>

func _ready():
	items["generic"] = preload("res://Assets/Misc/ItemRes/Whetstone.tres")
	items["whetstone"] = preload("res://Assets/Misc/ItemRes/Whetstone.tres")

func GetItem(itemNameIn) -> ItemRes:
	if itemNameIn in items:
		return items[itemNameIn]
	else:
		return items["generic"]
