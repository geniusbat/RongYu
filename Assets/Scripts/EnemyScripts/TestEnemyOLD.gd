extends KinematicBody2D

#Parameters
export(int) var SPEED = 100
export(float) var knockbackTime = 1.0
export(bool) var needVisionForAttack = false

enum {idle,randomWalk,searching,following,goingAround}
var state
var attacking:bool
var isKnocked:bool
var moveSpeed:int
var axis:Vector2
var movement:Vector2
var target
var path : PoolVector2Array

var weapon

var health:int
var speedMod:float

func _ready():
	$Line2D.set_as_toplevel(true)
	$KnockbackTimer.wait_time=knockbackTime
	target=null;state=idle; attacking=false; isKnocked=false;path=[]
	health=0;speedMod=1;
	if $Weapon.get_child_count()>0:
		weapon=$Weapon.get_child(0)
	else:
		weapon=0

func _physics_process(delta):
	if !isKnocked:
		match(state):
			idle:
				pass
			randomWalk:
				pass
			following:
				#Check if target null to go back to idle
				if target==null:
					state=idle
				#Target exists, follow it
				else:
					RotateWeaponTowardsTarget()
					AttackLogic()
					#If finished current path, get a new one
					if path.size()==0:
						path=GetNewPathToPoint(target.global_position)
					else:
						MoveFollowPath()
		moveSpeed=SPEED*speedMod
	else:
		moveSpeed=SPEED/1.5
		Move(axis,moveSpeed)

#All the logic behind attacking the target
func AttackLogic():
	if !attacking:
		var players=$MeleeRange.get_overlapping_areas()
		#Check if detected players
		if players!=null and players.size()>0:
			#Need vision to damage
			if needVisionForAttack:
				for el in players:
					if !CanSeeTarget(el):
						return
			#Dont need vision to damage
			attacking=true
			weapon.Attack()

#Rotates weapon towards the target
func RotateWeaponTowardsTarget():
	if target!=null and !attacking:
		weapon.look_at(target.global_position)

func Move(direction,speed):
	movement=move_and_slide(direction*speed)

#Move along path variable
func MoveFollowPath():
	var curPos=path[0]
	if global_position.distance_to(curPos)>10:
		Move((curPos-global_position).normalized(),moveSpeed)
	else:
		path.remove(0)
	$Line2D.points=path

#Applied whenever you want the enemy to be knocked, you need to declare a directionof the knockback
func Knockback(direction):
	#Only be knocked back if isnt already knocked, dashing or cant be knocked back
	if !isKnocked:
		isKnocked=true
		axis=direction
		$KnockbackTimer.start()

func TimedProcess():
	#Detect players and set as target the nearest one
	var players=$DetectionRange.get_overlapping_bodies()
	var distance=200
	for el in players:
		var currentDist=global_position.distance_to(el.global_position)
		if currentDist<distance and CanSeeTarget(el):
			target=el
			distance=currentDist
			state=following
#			state=following
	if target!=null:
		if state==following:
			#Update path
			path=GetNewPathToPoint(target.global_position)

func CanSeeTarget(targetPlayer):
	$Vision.set_cast_to(to_local(targetPlayer.global_position+Vector2(0,5)))
	$Vision.force_raycast_update()
	var col = $Vision.get_collider()
	if col!=null and col.is_in_group("Players"):
		return true
	else:
		return false

func KnockbackTimerTimeout():
	axis=Vector2.ZERO
	isKnocked=false

#Returns a path from the enemy to the pos
func GetNewPathToPoint(pos):
	var a : Navigation2D
	a=get_parent()
	return a.get_simple_path(global_position,pos)

