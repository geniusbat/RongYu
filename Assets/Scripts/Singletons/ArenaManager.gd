extends Node

onready var next = preload("res://Objects/Misc/Arenas/TestArena.tscn")
onready var arena = preload("res://Levels/test2.tscn")

export(bool) var initialArea = true

#This will load the previous player state and will make the level's player match the same properties
func LoadAndSpawnPlayer():
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
		player.HealthChanged()
		#Assign weapons
		if player.get_node("Weapon").get_child_count()>0:
			player.get_node("Weapon").get_child(0).free()
		if dic["weaponRef"]!="":
			player.get_node("Weapon").add_child(load(dic["weaponRef"]).instance())
			player.weapon = player.get_node("Weapon").get_child(0)
		else:
			player.weapon=null
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
		#Coins
		var currency = player.get_node("GUI/Currency")
		#Delete all possible coins before adding the correct amount
		for el in currency.get_children():
			el.queue_free()
		#Add the correct ammount
		i = 1
		while i <= dic["coins"]:
			#Check if last coin resource
			if i == dic["coins"]:
				currency.AddCoins(dic["lastCoinAmount"])
			#Add 100 to fill it
			else:
				currency.AddCoins(100)
			i+=1
		#I STILL NEED TO LOAD THE ENTITIES
	else:
		initialArea=false

#Call this to begin the game 
func StartArena():
	var _a = get_tree().change_scene_to(preload("res://Levels/test.tscn"))
	initialArea=false

#Change the arena to a new one
func ChangeArena():
	get_tree().get_root().find_node("OutsideArena",true,false).count=false
	FileManager.SavePlayer()
	print_debug("Arena Changed")
	var _a = get_tree().change_scene_to(arena)
	call_deferred("LoadAndSpawnPlayer")

#Go back to the menu properly
func GoToMenu():
	get_tree().get_root().find_node("OutsideArena",true,false).count=false
	var _a = get_tree().change_scene_to(preload("res://Levels/MainMenu.tscn"))
