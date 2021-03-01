extends Node2D

export(Array) var listOfEnemies 
var usedSpawns : Array
onready var spawns = $Spawns.get_children()
onready var rng = RandomNumberGenerator.new()
onready var ySort = get_node("../YSort")

func _ready():
	rng.randomize()
	var navigation = ySort.get_node("Navigation")
	#Spawn a random enemy from the list, it caps to the ammount of spawnPositions
	usedSpawns=spawns
	var usedList = listOfEnemies
	var size = min(spawns.size(),usedList.size())
	for _i in range(size):
		var enemyRef = usedList[rng.randi_range(0,usedList.size()-1)]
		var enemy = enemyRef.instance()
		var spawn = usedSpawns[rng.randi_range(0,spawns.size()-1)]
		usedList.erase(enemyRef)
		usedSpawns.erase(spawn)
		navigation.add_child(enemy)
		enemy.global_position=spawn.global_position


func TimedStep():
	#Check if no more enemies, then spawn teleporter
	if get_tree().get_nodes_in_group("Enemies").size()==0:
		ChangeToNextArena()

#Run this whenever you want to change arena. RUN THIS INSTEAD OF THE ONE IN THE ARENA MANAGER
func ChangeToNextArena():
	#Deactivate outside area
#	$OutsideArena.count=false
	get_tree().get_root().find_node("ArenaManager",true,false).ChangeArena()
