extends Node2D

#Deprecated, use the player teleporter detector
func ChangeToNextArena():
	#Deactivate outside area
#	$OutsideArena.count=false
	ArenaManager.ChangeArena()
