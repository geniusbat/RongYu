extends Node

#This will save the current state of the player
func SavePlayer():
	var file = File.new()
	var player = get_tree().get_root().find_node("Player",true,false)
	var dic = {
		"speedMod" : player.speedMod,
		"damageMod" : player.damageMod,
		"maxHealth" : player.maxHealth,
		"inventorySize" : player.inventorySize,
		"maxEnemiesInsideInfluence" : player.maxEnemiesInsideInfluence,
		"armour" : player.armour,
		"luck" : player.luck,
		"health" : player.health,
		"critical" : player.critical,
		"coins" : player.get_node("GUI/Currency").get_child_count()
	}
	#Assign last coins value
	if dic["coins"]==0:
		dic["lastCoinAmount"]=0
	else:
		dic["lastCoinAmount"]=player.get_node("GUI/Currency").get_child(dic["coins"]-1).value
	#Assign weapon
	if player.get_node("Weapon").get_child_count()>0:
		dic["weaponRef"] = player.get_node("Weapon").get_child(0).res.weaponNode
	else:
		dic["weaponRef"] = ""
	#Assign items
	var i = 0
	while i < player.inventorySize:
		dic["item"+String(i)]=""
		dic["itemExtra"+String(i)]=""
		i+=1
	for el in player.get_node("Items").get_children():
		var itemRes = el.itemInfo
		dic["item"+String(el.get_index())]=itemRes.item
		#Save extra info about items if necessary
		if itemRes.innerName == "bagOfFlowers":
			dic["itemExtra"+String(el.get_index())]=el.bar.value
		else:
			dic["itemExtra"+String(el.get_index())]=""
	file.open("user://Player.labo",File.WRITE)
	file.store_string(to_json(dic))
	file.close()

#Returns dic of the player with all of their info
func LoadPlayerInfo() -> Dictionary:
	var dic : Dictionary
	var file = File.new()
	file.open("user://Player.labo",File.READ)
	dic = parse_json(file.get_as_text())
	return dic
