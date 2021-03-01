extends Control



func PlayButtonPressed():
	ArenaManager.StartArena()

func OptionsButtonPressed():
	$OptionsMenu.popup()

func ExitButtonPressed():
	get_tree().quit()
