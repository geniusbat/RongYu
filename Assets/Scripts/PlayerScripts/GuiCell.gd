extends Control

func _ready():
	var _a=$TextureButton.connect("mouse_entered",get_parent(),"MouseEnteredCell",[get_index()])
	_a=$TextureButton.connect("mouse_exited",get_parent(),"MouseExitedCell",[get_index()])
	_a=$TextureButton.connect("button_down",get_parent(),"MouseClickedCell",[get_index()])
