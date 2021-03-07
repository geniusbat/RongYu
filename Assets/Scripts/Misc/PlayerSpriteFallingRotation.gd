extends Sprite

export(float)var rotSpeed = 1

func _physics_process(delta):
	rotate(delta*rotSpeed)
