extends Camera2D

export(float) var maxMagnitude = 20
export(float) var camSpeed = 10
export(float) var deAcc = 0.5
onready var player = get_parent()
var playerPos : Vector2
var pos : Vector2
var screenShakePos : Vector2
var magnitude : float
var time : float

func _ready():
	magnitude=0
	time=0
	screenShakePos = Vector2(0,0)
	set_as_toplevel(true)

func _physics_process(delta):
	if magnitude>0:
		time+=delta+magnitude
		screenShakePos=Vector2(sin(time),cos(time))*magnitude
		magnitude-=deAcc
	pos = player.global_position+screenShakePos
	global_position=global_position.linear_interpolate(pos,camSpeed*delta)

func ScreenShake(magnitudeIn):
	magnitude=clamp(magnitudeIn,magnitudeIn,maxMagnitude)
	time=0
