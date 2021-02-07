extends Node

var itemInfo : ItemRes = preload("res://Assets/Misc/ItemRes/Whetstone.tres")

func _ready():
	#Connect to damage signal
	var _a=get_node("../..").connect("enemyDamaged",self,"EnemyDamaged")

func EnemyDamaged(enemy):
	enemy.DamageWithoutKnockbackAndTimer(1)
