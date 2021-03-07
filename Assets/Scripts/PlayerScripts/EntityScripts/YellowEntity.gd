extends Node
onready var player = get_node("../..")

func _ready():
	player.bonusCritical+=200

func _exit_tree():
	player.bonusCritical-=200
