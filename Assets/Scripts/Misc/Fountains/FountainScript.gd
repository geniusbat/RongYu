extends StaticBody2D

export(String,"Red","Green","Blue","Yellow","Purple") var entityRepresented = "Red"

onready var player = get_tree().get_root().find_node("Player",true,false)
onready var area = $DetectObjects

func _ready():
	#Set correct coloration
	match(entityRepresented):
		"Red":
			modulate=Color("ffb6b6")
		"Green":
			modulate=Color("b7ffb6")
		"Blue":
			modulate=Color("58a5ff")
		"Yellow":
			modulate=Color("ffe68f")
		"Purple":
			modulate=Color("efabff")

func StepProcess():
	if player==null:
		player = get_tree().get_root().find_node("Player",true,false)
	#Detect floor items
	var list = area.get_overlapping_areas()
	for el in list:
		#Check if it is an item
		if "isWeapon" in el.get_parent():
			el.get_parent().queue_free()
			player.emit_signal("sacrificeDone",entityRepresented)
			player.IncreaseAffinity(entityRepresented)
