extends Node2D

onready var player = preload("res://Objects/Player/Player.tscn")
onready var floorItem = preload("res://Objects/Items/FloorItemGeneric.tscn")
func _ready():
	$AnimationPlayer.play("IntroAnimation")

func SetPlayer():
	#Player
	$AnimationPlayer.queue_free()
	var a = player.instance()
	a.position=$Sprite.position
	if a.get_node("Weapon").get_child_count()>0:
		a.get_node("Weapon").get_child(0).queue_free()
	$Sprite.queue_free()
	add_child(a)
	#Weapons
	var ins = floorItem.instance()
	ins.position=$ArenaNode/Position2D.global_position
	add_child(ins)
	ins.Create(load("res://Assets/Misc/WeaponRes/Knife.tres"),true,Vector2.ZERO)
	
	ins = floorItem.instance()
	ins.position=$ArenaNode/Position2D2.global_position
	add_child(ins)
	ins.Create(load("res://Assets/Misc/WeaponRes/TestWeapon.tres"),true,Vector2.ZERO)
