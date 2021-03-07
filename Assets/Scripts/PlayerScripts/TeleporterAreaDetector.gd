extends Area2D

onready var label = $Label
var teleporter

func _ready():
	set_process_input(false)

func _input(event):
	if event.is_action_pressed("interact"):
		ArenaManager.ChangeArena()

func _on_TeleporterAreaDetector_area_entered(area):
	if area.get_name()=="Teleporter":
		print_debug("Entered")
		teleporter=area
		set_process_input(true)
		label.visible=true


func _on_TeleporterAreaDetector_area_exited(area):
	if area.get_name()=="Teleporter":
		set_process_input(false)
		label.visible=false
