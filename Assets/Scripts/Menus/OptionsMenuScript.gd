extends Popup




func ClosePopupButtonPressed():
	hide()


func FullscreenTogglePressed():
	OS.window_fullscreen = $CheckBox.pressed
