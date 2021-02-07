extends Camera2D

export(float) var camSpeed = 10
onready var player = get_parent()
var playerPos : Vector2

func _ready():
	set_as_toplevel(true)

func _physics_process(delta):
	playerPos = player.global_position
	global_position=global_position.linear_interpolate(playerPos,camSpeed*delta)
