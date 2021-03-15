extends Node

var itemInfo : ItemRes = preload("res://Assets/Misc/ItemRes/BagOfFlowers.tres")
onready var bar = $TextureRect
onready var oldIndex = 5
onready var player = get_node("../..")
onready var flowerParticles = preload("res://Objects/Misc/Particles/FlowerParticles.tscn")

func _ready():
	player.connect("enemyKilled",self,"EnemyKilled")

#STANDARD ITEM CALLs
#Call this when item created
func ItemWasAdded():
	_on_Timer_timeout()
#Call this when item was removed
func ItemWasDeleted():
	bar.queue_free()
#Call this when it is important to draw thing under the cell
func ItemIndexChanged(newCell):
	pass

func EnemyKilled(enemyPos):
	if enemyPos==null:
		return
	#Generate particles on enemy
	var ins = flowerParticles.instance()
	ins.global_position = enemyPos
	get_tree().get_root().add_child(ins)
	bar.value+=2
	#Max value, add coins
	if bar.value==10:
		bar.value=0
		player.AddCoins(100)

func _on_Timer_timeout():
	if get_index()!=oldIndex:
		bar.get_parent().remove_child(bar)
		get_parent().get_parent().get_node("GUI/Inventory").get_child(get_index()).add_child(bar)
