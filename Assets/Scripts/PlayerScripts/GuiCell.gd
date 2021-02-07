extends Control

func _ready():
	$TextureButton.connect("mouse_entered",get_parent(),"MouseEnteredCell",[get_index()])
	$TextureButton.connect("mouse_exited",get_parent(),"MouseExitedCell",[get_index()])
	$TextureButton.connect("button_down",get_parent(),"MouseClickedCell",[get_index()])
