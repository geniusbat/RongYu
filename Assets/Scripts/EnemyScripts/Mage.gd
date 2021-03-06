extends KinematicBody2D


export(float) var SPEED = 100
export(float) var timeKnock = 1
export(float) var timeDamage = 1
export(int) var health = 1
export(int) var damage = 1

var path : PoolVector2Array

#References
onready var player = get_tree().get_root().find_node("Player",true,false)
onready var detectionRange = $DetectionRange
onready var meleeRange = $MeleeRange 
onready var knockbackTimer = $KnockbackTimer
onready var damageAgainTimer = $DamageAgainTimer
onready var vision = $Vision
onready var attackTimer = $AttackTimer
onready var shootPosition = $Sprite/Position2D
onready var visibility = $VisibilityNotifier2D
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
onready var projectile = preload("res://Objects/Enemies/MageProjectile.tscn")

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
#	Damage(30,(Vector2.UP))
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
				var distance = global_position.distance_to(player.global_position)
				#Move
				#Check if can go in
				if (distance>180):
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
						Attack()
						attackTimer.start()
						attacking=true
			goingAround:
				#Try to attack
				if !attacking:
					if meleeRange.get_overlapping_areas().size()>0:
						#Attack
						Attack()
						attackTimer.start()
						attacking=true
				#Moving
				if path.size()>0:
					moveSpeed=SPEED*0.5
					MoveAlongPath()
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
			if (insideInfluence or player.CanEnemyGoIn())and(rng.randi_range(0,10)<3):
				state=following
				path=GetPathTowardsPoint(player.global_position)
			#Renew path randomly if finished the current path
			elif path.size()==0:
				if rng.randi_range(0,10)<=-1:
					path=GetPathTowardsPoint(global_position+Vector2(rng.randi_range(-100,100),rng.randi_range(-50,50)))
			#Renew randomly
			else:
				if rng.randi_range(0,10)<=1:
					path=GetPathTowardsPoint(global_position+Vector2(rng.randi_range(-100,100),rng.randi_range(-50,50)))
			$Line2D.points=path
		dead:
			pass

#DAMAGE FUNCTIONS
#Damage enemy and knock it
func Damage(dam,dir):
	if canReceiveDamage:
		health-=dam
		#Die if necessary
		if health <= 0:
			Die(dir)
		else:
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
#Detect player if inside radius and start following him
func DetectPlayerAndFollow():
	if detectionRange.get_overlapping_bodies().size()>0:
		state=following
		path=GetPathTowardsPoint(player.global_position)
		$Line2D.points=path
#Die, when dead, delete most of stuff
func Die(direction):
	player.emit_signal("enemyKilled",self)
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
	queue_free()
#TODO, when enemy falls from arena
func DieByFalling():
	print("Enemy fell")
	player.emit_signal("enemyKilled",self)
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
func Attack():
	#Check for vision
	if visibility.is_on_screen():
		vision.cast_to=to_local(player.global_position)
		vision.force_raycast_update()
		if vision.get_collider()!=null:
			if vision.get_collider().get_parent().get_name()=="Player":
				var ins = projectile.instance()
				get_parent().add_child(ins)
				ins.global_position=shootPosition.global_position
				ins.direction=(player.global_position-ins.global_position).normalized()
#TIMERS FINISHING
func KnockbackTimerTimeout():
	isKnockedback=false
func DamageAgainTimerTimeout():
	canReceiveDamage=true

func AttackTimerTimeout():
	attacking=false
