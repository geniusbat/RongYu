extends Node2D

var itemInfo : ItemRes
var weaponInfo : WeaponRes
var isWeapon : bool #If it is weapon or item
var direction
export(float) var speed = 90
export(float) var deacc = 3

onready var raycast : RayCast2D = $RayCast2D

func _ready():
	isWeapon=false
	Create(ItemManager.GetRandomItem(),isWeapon,Vector2(0,0))

func _physics_process(delta):
	if speed > 0:
		translate(direction*delta*speed)
		speed -= deacc
		#Stop if raycast collides
		if raycast.get_collider()!=null:
			speed = 0
	else:
		set_physics_process(false)

func Create(info,weaponI,dirI):
	isWeapon=weaponI
	if isWeapon:
		weaponInfo=info
		$Sprite.texture=weaponInfo.floorSprite
	else:
		itemInfo=info
		$Sprite.texture=itemInfo.floorSprite
	direction=dirI
	$RayCast2D.cast_to=direction
