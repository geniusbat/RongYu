extends Node

export(bool) var initialArea = true
onready var musicVolume : float = 0
onready var effectVolume : float = 0
onready var arena = preload("res://Levels/test2.tscn")
onready var rng = RandomNumberGenerator.new()
var levels : Array
var arenaMusic : Array
var currentMusicIndex : int
var musicPlayer : AudioStreamPlayer
var levelNumber : int
var musicBus 
var effectBus

func _init():
	#Add music player
	musicPlayer = AudioStreamPlayer.new()
	add_child(musicPlayer)
	musicPlayer.bus="Music"

func _ready():
	rng.randomize()
	var _a = musicPlayer.connect("finished",self,"MusicFinished")
	#Set up possible music for arena battles
#	arenaMusic.append(preload("res://Assets/Audio/Music/BeepBox-Song.wav"))
	arenaMusic.append(preload("res://Assets/Audio/Music/ether-vox.wav"))
	#Set music buses
	musicBus=AudioServer.get_bus_index("Music")
	effectBus=AudioServer.get_bus_index("Master")
	#Set up disponible levels
#	levels.append(preload("res://Levels/test2.tscn"))
	levels.append(preload("res://Levels/test.tscn"))
#	levels.append(preload("res://Levels/Level00.tscn"))
#	levels.append(preload("res://Levels/Level01.tscn"))
#	levels.append(preload())
	

#Call this  when volume variables change to set them to the buses
func VolumeChanged():
	AudioServer.set_bus_volume_db(musicBus,musicVolume)
	AudioServer.set_bus_volume_db(effectBus,effectVolume)
	print(AudioServer.get_bus_volume_db(musicBus))

#Plays a random track from the arenamusic list
func GetAndPlayRandomTrack():
	var num = rng.randi_range(0,arenaMusic.size()-1)
	musicPlayer.stream=arenaMusic[num]
	currentMusicIndex=num
	musicPlayer.play()

#Music finished, play more if necessary
func MusicFinished():
	GetAndPlayRandomTrack()

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
		#Loading entities
		player.entities["Red"]=dic["Red"]
		player.entities["Green"]=dic["Green"]
		player.entities["Blue"]=dic["Blue"]
		player.entities["Purple"]=dic["Purple"]
		player.entities["Yellow"]=dic["Yellow"]
		#Spawn entity scene if necessary
		if dic["usedEntity"] != "":
			var usedEntity = load("res://Objects/Player/Entities/"+dic["usedEntity"]+".tscn").instance()
			player.get_node("Entity").add_child(usedEntity)
	else:
		initialArea=false

#Call this to begin the game 
func StartArena():
	levelNumber+=1
	var _a = get_tree().change_scene_to(preload("res://Levels/Intro.tscn"))
	GetAndPlayRandomTrack()
	initialArea=false

#Change the arena to a new one
func ChangeArena():
	levelNumber+=1
	get_tree().get_root().find_node("OutsideArena",true,false).count=false
	FileManager.SavePlayer()
	print_debug("Arena Changed")
	#select a random arena if necesary
	arena=levels[rng.randi_range(0,levels.size()-1)]
	var _a = get_tree().change_scene_to(arena)
	call_deferred("LoadAndSpawnPlayer")

#Go back to the menu properly
func GoToMenu():
	get_tree().get_root().find_node("OutsideArena",true,false).count=false
	var _a = get_tree().change_scene_to(preload("res://Levels/MainMenu.tscn"))
