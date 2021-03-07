extends Popup




func ClosePopupButtonPressed():
	hide()


func FullscreenTogglePressed():
	OS.window_fullscreen = $CheckBox.pressed


func MusicVolumeChanged(value):
	ArenaManager.musicVolume=value
	ArenaManager.VolumeChanged()

func EffectVolumeChanged(value):
	ArenaManager.effectVolume=value
	ArenaManager.VolumeChanged()
