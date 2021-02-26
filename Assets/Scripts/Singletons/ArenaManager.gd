extends Node

onready var next = preload("res://Objects/Misc/Arenas/TestArena.tscn")
onready var arena = preload("res://Levels/test2.tscn")

export(bool) var initialArea = true

func _ready():
	#If not is an initial area, it means that there should be player info from previous arenas
	if !initialArea:
		print_debug("Loading")
		#Get player ref
		var player = get_tree().get_root().find_node("Player",true,false)
		var dic = FileManager.LoadPlayerInfo()
		player.armour = dic["armour"]
		player.maxHealth = dic["maxHealth"]
		player.health = dic["health"]
		player.luck = dic["luck"]
		player.critical = dic["critical"]
		player.inventorySize = dic["inventorySize"]
		player.maxEnemiesInsideInfluence = dic["maxEnemiesInsideInfluence"]
		player.speedMod = dic["speedMod"]
		player.damageMod = dic["damageMod"]
		#Assign weapons
		if player.get_node("Weapon").get_child_count()>0:
			player.get_node("Weapon").get_child(0).free()
		if dic["weaponRef"]!="":
			player.get_node("Weapon").add_child(load(dic["weaponRef"]).instance())
		player.weapon = player.get_node("Weapon").get_child(0)
		#Assign items
		var i = 0
		while i < player.inventorySize:
			var a = dic["item"+String(i)]
			if a != "":
				var item = load(a).instance()
				player.get_node("Items").add_child(item)
				player.get_node("GUI/Inventory").AddItem(item)
				#Assign extra info on item
				if item.get_name()=="BagOfFlowers":
					item.bar.value=dic["itemExtra"+String(i)]
			i+=1
	else:
		initialArea=false

func ChangeArena():
	FileManager.SavePlayer()
	print_debug("Arena Changed")
	var _a = get_tree().change_scene_to(arena)
	call_deferred("_ready")
