extends Area2D

onready var label = $Label
onready var player = get_tree().get_root().find_node("Player",true,false)
onready var generic = preload("res://Objects/Items/FloorItemGeneric.tscn")
var currencySystem
func _ready():
	label.visible=false
	set_process_input(false)
	currencySystem=player.get_node("GUI/Currency")

func _input(event):
	if event.is_action_pressed("interact"):
		#Generate empty item if necesary
		#Check if correct ammount of money
		#If only one coin holder check for 100
		if currencySystem.get_child_count()==1:
			if currencySystem.get_child(0).value==100:
				Sell()
				currencySystem.get_child(0).value=0
		#More children
		elif currencySystem.get_child_count()>1:
			Sell()
			currencySystem.get_child(0).queue_free()

func Sell():
	#Add item
	var instance = generic.instance()
	add_child(instance)
	instance.Create(load("res://Assets/Misc/ItemRes/Skull.tres"),false,Vector2.ZERO)
	player.AddItem(instance)

func _on_Trader_area_entered(_area):
	label.visible=true
	set_process_input(true)
func _on_Trader_area_exited(_area):
	print("EXIT")
	label.visible=false
	set_process_input(false)
