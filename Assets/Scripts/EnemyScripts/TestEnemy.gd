extends KinematicBody2D

export(float) var SPEED = 100
export(float) var timeKnock = 1
export(float) var timeDamage = 1
export(int) var health = 2
export(int) var damage = 1

var path : PoolVector2Array

#References
onready var player = get_tree().get_root().find_node("Player",true,false)
onready var weapon = $Weapon.get_child(0)
onready var detectionRange = $DetectionRange
onready var meleeRange = $MeleeRange 
onready var knockbackTimer = $KnockbackTimer
onready var damageAgainTimer = $DamageAgainTimer
onready var vision = $Vision
onready var damagedStream = $DamagedStream
var navigation : Navigation2D
#
var axis : Vector2
var movement : Vector2
var moveSpeed : float
var state
enum {idle,randomWalk,following,goingAround,dead}
onready var attacking = false 
onready var isKnockedback = false
onready var canReceiveDamage = true
onready var insideInfluence : bool = false
onready var rng = RandomNumberGenerator.new()
onready var coin = preload("res://Objects/Player/Coins.tscn")
onready var deadEnemy = preload("res://Objects/Enemies/DeadEnemy.tscn")
onready var blood = preload("res://Objects/Misc/Particles/BloodParticles.tscn")
#Remember, we dont have windup as the windup time will be taken into consideration in the weapon animation time

#Mods
export(float) var speedMod = 1

func _ready():
	rng.randomize()
	moveSpeed=SPEED
	$Line2D.set_as_toplevel(true)
	knockbackTimer.wait_time=timeKnock
	damageAgainTimer.wait_time=timeDamage
	state = idle
	navigation= get_parent() 
	#Connect to timers
	if true:
		knockbackTimer.connect("timeout",self,"KnockbackTimerTimeout")
#		damageAgainTimer.connect("timeout",self,"DamageAgainTimerTimeout")
		var _a = $TimedProcess.connect("timeout",self,"TimedProcess")

func _physics_process(_delta):
	PrintState()
	#Being knocked
	if isKnockedback:
		var _a=move_and_slide(axis*SPEED*0.8,Vector2.ZERO)
	#Not being knocked
	else:
		moveSpeed=SPEED
		match(state):
			idle:
				pass
			randomWalk:
				pass
			following:
				RotateWeaponTowardsPlayer()
				var distance = global_position.distance_to(player.global_position)
				#Move
				#Check if can go in
				if (insideInfluence or player.CanEnemyGoIn())or(distance>500):
					#Only move if path is set or available
					if path.size()>0:
						#Set moveSpeed
						if distance < 10:
							moveSpeed = SPEED*-1
						elif distance < 30:
							moveSpeed = SPEED*0.1
						elif distance < 200:
							moveSpeed = SPEED*0.6
						#Move
						MoveAlongPath()
						AlignSprite()
					#Restart
					else:
						state=idle
						DetectPlayerAndFollow()
				#Cant go in, move around
				else:
					state=goingAround
					#Get random new path
					var newPos=Vector2(rng.randi_range(-100,100),rng.randi_range(-100,100))
					path=GetPathTowardsPoint(global_position+newPos)
					$Line2D.points=path
				#Try to attack
				if !attacking:
					if meleeRange.get_overlapping_areas().size()>0:
						#Attack
						weapon.Attack()
						attacking=true
			goingAround:
				RotateWeaponTowardsPlayer()
				#Try to attack
				if !attacking:
					if meleeRange.get_overlapping_areas().size()>0:
						#Attack
						weapon.Attack()
						attacking=true
				#Moving
				if path.size()>0:
					moveSpeed=SPEED*0.6
					MoveAlongPath()
					AlignSprite()
			dead:
				pass

func TimedProcess():
	match(state):
		idle:
			DetectPlayerAndFollow()
		randomWalk:
			DetectPlayerAndFollow()
		following:
			#Update path towards player randomly
			if rng.randi_range(0,10) > 3:
				path = GetPathTowardsPoint(player.global_position)
		goingAround:
			#Try to go in if at least some ammount of the path was done
			if (insideInfluence or player.CanEnemyGoIn())and(path.size()<3):
				state=following
				path=GetPathTowardsPoint(player.global_position)
			#Renew path randomly if finished the current path
			elif path.size()==0:
				if rng.randi_range(0,10)<=5:
					path=GetPathTowardsPoint(global_position+Vector2(rng.randi_range(-100,100),rng.randi_range(-50,50)))
			#Renew randomly
			else:
				if rng.randi_range(0,10)<=2:
					path=GetPathTowardsPoint(global_position+Vector2(rng.randi_range(-100,100),rng.randi_range(-50,50)))
			$Line2D.points=path
		dead:
			pass

#DAMAGE FUNCTIONS
#Damage enemy and knock it
func Damage(dam,dir):
	if canReceiveDamage:
		damagedStream.play()
		health-=dam
		#Die if necessary
		if health <= 0:
			var ins = blood.instance()
			get_parent().add_child(ins)
			ins.followTarget=false
			ins.global_position=global_position
			Die(dir)
		else:
			var ins = blood.instance()
			get_parent().add_child(ins)
			ins.followTarget=true
			ins.target=self
			ins.global_position=global_position
			player.emit_signal("enemyDamaged",self)
			canReceiveDamage=false
			damageAgainTimer.start()
		Knockback(dir)
#Damage but without knocking nor counting if can damage again
func DamageWithoutKnockbackAndTimer(dam):
	health-=dam
	#Die if necessary
	if health <= 0:
		Die(Vector2.ZERO)
func Knockback(dir):
	axis=dir
	isKnockedback=true
	knockbackTimer.start()

#MOVING FUNCTIONS
#Will move along path, use this if and only if there are points in path. Remember it will align sprite
func MoveAlongPath():
	var pos = path[0]
	axis = (pos-position).normalized()
	var _a = move_and_slide(axis*moveSpeed*speedMod)
	AlignSprite()
	#Check distance and if near, delete
	if position.distance_to(pos)<10:
		path.remove(0)
#Will align sprite towards axis 
func AlignSprite():
	var dir = axis.x
	if dir>0:
		$Sprite.flip_h=false
	elif dir<0:
		$Sprite.flip_h=true

#RANDOM FUNCTIONS
#Rotates weapon towards the player if not attacking
func RotateWeaponTowardsPlayer():
	if !attacking:
		weapon.look_at(player.global_position)
#Detect player if inside radius and start following him
func DetectPlayerAndFollow():
	if detectionRange.get_overlapping_bodies().size()>0:
		state=following
		path=GetPathTowardsPoint(player.global_position)
		$Line2D.points=path
#Die, when dead, delete most of stuff
func Die(direction):
	player.emit_signal("enemyKilled",global_position)
	state=dead
	var ins = deadEnemy.instance()
	ins.global_position=global_position
	ins.get_node("Sprite").texture=$Sprite.texture
	if $Sprite.region_enabled:
		ins.get_node("Sprite").region_enabled=true
		ins.get_node("Sprite").region_rect=$Sprite.region_rect
	ins.get_node("Sprite").rotation_degrees=90
	ins.get_node("Sprite").flip_h=$Sprite.flip_h
	ins.get_node("CollisionShape2D").shape=$MovementCollision.shape
	ins.dir=direction
	get_parent().call_deferred("add_child",ins)
	ins = coin.instance()
	ins.global_position=global_position
	get_parent().add_child(ins)
	queue_free()
#TODO, when enemy falls from arena
func DieByFalling():
	print("Enemy fell")
	player.emit_signal("enemyKilled",global_position)
	state=dead
	var ins = deadEnemy.instance()
	ins.global_position=global_position
	ins.get_node("Sprite").texture=$Sprite.texture
	if $Sprite.region_enabled:
		ins.get_node("Sprite").region_enabled=true
		ins.get_node("Sprite").region_rect=$Sprite.region_rect
	ins.get_node("Sprite").rotation_degrees=90
	ins.get_node("Sprite").flip_h=$Sprite.flip_h
	ins.get_node("CollisionShape2D").shape=$MovementCollision.shape
	ins.dir=Vector2.ZERO
	get_parent().call_deferred("add_child",ins)
	ins = coin.instance()
	ins.global_position=global_position
	get_parent().add_child(ins)
	ins.Fall()
	queue_free()
#Get path towards global_position of point
func GetPathTowardsPoint(globalPos:Vector2):
	return navigation.get_simple_path(position,navigation.to_local(globalPos))
#Print the state of the enemy
func PrintState():
	match(state):
		idle:
			$Label.text="State: Idle"
		following:
			$Label.text="State: Following"
		randomWalk:
			$Label.text="State: RandomWalk"
		goingAround:
			$Label.text="State: GoingAround"

#TIMERS FINISHING
func KnockbackTimerTimeout():
	isKnockedback=false
func DamageAgainTimerTimeout():
	canReceiveDamage=true
