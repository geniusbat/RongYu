extends Node

var items : Dictionary
#Items is a dictionary of <itemName,ItemResource>
onready var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	items["generic"] = preload("res://Assets/Misc/ItemRes/Whetstone.tres")
	items["whetstone"] = preload("res://Assets/Misc/ItemRes/Whetstone.tres")
	items["bagOfFlowers"] = preload("res://Assets/Misc/ItemRes/BagOfFlowers.tres")
	items["brambleBand"] = preload("res://Assets/Misc/ItemRes/BrambleBand.tres")
	items["jadeArmour"] = preload("res://Assets/Misc/ItemRes/JadeArmour.tres")

func GetItem(itemNameIn) -> ItemRes:
	if itemNameIn in items:
		return items[itemNameIn]
	else:
		return items["generic"]

func GetRandomItem() -> ItemRes:
	var num = rng.randi_range(1,items.size()-1)
	return items.values()[num]
