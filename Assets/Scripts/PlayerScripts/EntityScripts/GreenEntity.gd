extends Node2D

onready var player = get_node("../..")
onready var rng = RandomNumberGenerator.new()
onready var damageArea = preload("res://Objects/Player/Entities/DamageAreaBlueEntity.tscn")
func _ready():
	rng.randomize()
	var _a = player.connect("playerDamaged",self,"PlayerDamaged")

func PlayerDamaged():
	#Spawn aura if necessary
	var num = rng.randi_range(0,100)
	print(num)
	if num<50+(player.luck+player.bonusLuck):
		#TODO Change to the proper area damage instead of using the blue entity one
		var ins = damageArea.instance()
		player.get_parent().call_deferred("add_child",ins)
