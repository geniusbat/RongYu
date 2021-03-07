extends Node2D

onready var player = get_node("../..")
onready var currencySystem = get_node("../../GUI/Currency")
onready var timer = $InvulnerableTimer

func _input(event):
	#Generate aura and make invulnerable if necessary when trying to dash
	if event.is_action_pressed("dash"):
		get_tree().set_input_as_handled()
		#Check if correct ammount of money
		#If only one coin holder check for 100
		if currencySystem.get_child_count()==1:
			if currencySystem.get_child(0).value==100:
				CreateAura()
				currencySystem.get_child(0).value=0
		#More children
		elif currencySystem.get_child_count()>1:
			currencySystem.get_child(0).queue_free()
			CreateAura()

#Activate the passive 
func CreateAura():
	player.notInvulnerable=false
	player.damageMod += 1
	timer.start()

func _exit_tree():
	if timer.time_left>0:
		player.damageMod -= 1
		player.notInvulnerable=true

func InvulnerableTimerTimeout():
	player.damageMod -= 1
	player.notInvulnerable=true
