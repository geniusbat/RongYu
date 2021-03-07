extends Node

onready var player = get_node("../..")
onready var damageArea = preload("res://Objects/Player/Entities/DamageAreaBlueEntity.tscn")

func _ready():
	var _a = player.connect("enemyKilled",self,"EnemyKilled")

func EnemyKilled(pos):
	var ins = damageArea.instance()
	ins.global_position=pos
	player.get_parent().call_deferred("add_child",ins)
