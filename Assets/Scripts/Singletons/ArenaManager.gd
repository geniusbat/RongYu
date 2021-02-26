extends Node

onready var next = preload("res://Objects/Misc/Arenas/TestArena.tscn")
onready var arena = preload("res://Levels/test2.tscn")

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("ui_accept"):
		ChangeArena()

func ChangeArena():
	print_debug("Arena Changed")
	var previousPlayer = get_tree().get_root().find_node("Player",true,false)
	var _a = get_tree().change_scene_to(arena)
	var player = get_tree().get_root().find_node("Player",true,false)
	
	#Assign correct weapon from prev player to new
	var weapon = player.get_node("Weapon")
	if weapon.get_child_count()>0:
		weapon.get_child(0).queue_free()
	if previousPlayer.get_node("Weapon").get_child_count()>0:
		weapon.add_child(previousPlayer.get_node("Weapon").get_child(0))

	#Take items from prev player and add it to current player
	
