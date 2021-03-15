extends Node2D

export(Array) var listOfEnemies 
export(bool) var entitiesSpawnOnEnd = false
export(bool) var traderSpawnOnEnd = false
var usedSpawns : Array
onready var spawns = $Spawns.get_children()
onready var rng = RandomNumberGenerator.new()
onready var ySort = get_node("../YSort")
onready var teleporter = $Teleporter
onready var entities = $Entities
onready var trader = $Trader
onready var spawnParticle = preload("res://Objects/Misc/Particles/SpawnEnemyParticles.tscn")

func _ready():
	rng.randomize()
	var navigation = ySort.get_node("Navigation")
	#Spawn a random enemy from the list, it caps to the ammount of spawnPositions
	usedSpawns=spawns
	var usedList = listOfEnemies.duplicate()
	var size = min(spawns.size(),usedList.size())
	for _i in range(size):
		var enemyRef = usedList[rng.randi_range(0,usedList.size()-1)]
		var enemy = enemyRef.instance()
		var spawn = usedSpawns[rng.randi_range(0,spawns.size()-1)]
		var part = spawnParticle.instance()
		usedList.erase(enemyRef)
		get_parent().call_deferred("add_child",part)
		usedSpawns.erase(spawn)
		navigation.add_child(enemy)
		enemy.global_position=spawn.global_position
		part.global_position=spawn.global_position

func TimedStep():
	#Check if no more enemies, then spawn teleporter
	if get_tree().get_nodes_in_group("Enemies").size()==0 and teleporter.visible!=true:
		ActivateTeleporter()

func ActivateTeleporter():
	teleporter.visible=true
	teleporter.monitorable=true
	teleporter.monitoring=true
	if entitiesSpawnOnEnd:
		entities.position=Vector2(0,0)
		entities.visible=true
	if traderSpawnOnEnd:
		trader.visible=true
		trader.get_node("CollisionShape2D").disabled=false
		trader.get_node("Label").visible=false

#Deprecated
func ChangeToNextArena():
	#Deactivate outside area
#	$OutsideArena.count=false
	get_tree().get_root().find_node("ArenaManager",true,false).ChangeArena()
