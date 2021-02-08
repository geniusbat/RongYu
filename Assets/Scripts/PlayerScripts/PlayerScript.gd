extends KinematicBody2D

const SPEED = 150
const DASH = 300
enum dashStates {normal,dashing,windup}
var dashState; var dashTime:float; var windupTime:float
var moveSpeed:float
var attacking:bool
var isKnocked:bool
var unKnockable:bool
var axis:Vector2
var movement:Vector2

#References
onready var interactArea = $InteractArea
onready var dashingTimer = $DashingTimer
onready var receiveDamageTimer = $ReceiveDamageTimer
onready var knockbackTimer = $KnockbackTimer
onready var inventory = $GUI/Inventory
onready var healthSystem = $GUI/HealthSystem
onready var currency = $GUI/Currency
onready var items = $Items
var weapon
#Misc states
var canReceiveDamage:bool #Used for non-item cases
#Mods
export(float) var speedMod = 1
export(float) var damageMod = 1
var immobile:bool
var notInvulnerable #Only used for items

#Stats
export(int) var maxHealth = 3
var health:int
var critical:int
var armor:int
var luck:int
export(int) var inventorySize:int = 3
#Influence
var enemiesInsideInfluence:int
export(int) var maxEnemiesInsideInfluence=3

signal enemyKilled(enemy); signal enemyDamaged(enemy)
signal playerAttacked
signal playerDamaged(damage); signal playerDashed; signal playerHealed(healed); signal playerKnocked; signal addedCoins(coins); 
signal criticalStrike(enemyA); signal armorBlocked; signal sacrificeDone; signal itemSpawned(item)

func _ready():
	#Setting up variables
	dashState=dashStates.normal; moveSpeed=SPEED; isKnocked=false; canReceiveDamage=true; attacking=false
	enemiesInsideInfluence=0; unKnockable=false; notInvulnerable=true
	dashTime=0.2; windupTime=0.5
	health=3
	armor=10
	luck=20
	critical=0
	#Initialize maxHealth drawen
	healthSystem.MaxHealthChanged(maxHealth)
	randomize()
	if $Weapon.get_child_count()>0:
		weapon=$Weapon.get_child(0)
	#Create weapon, failsafe option. TODO
	else:
		pass

func _unhandled_input(event):
	#Attack
	if event.is_action_pressed("left_click"):
		if weapon!=null:
			weapon.Attack()
			attacking=true
	#Release weapon
	elif event.is_action_pressed("leaveWeapon"):
		if weapon!=null:
			var floorItem = load("res://Objects/Items/FloorItemGeneric.tscn").instance()
			floorItem.global_position=global_position
			get_tree().get_root().get_child(0).add_child(floorItem)
			floorItem.Create(weapon.res,true,(get_global_mouse_position()-global_position).normalized())
			$Weapon.remove_child(weapon)
			weapon=null
	#Interact
	elif event.is_action_pressed("interact"):
		var things = interactArea.get_overlapping_areas()
		if things!=null:
			for area in things:
				var el = area.get_parent()
				#The thing is a weapon, try to pick up only if weapon slot empty
				if weapon==null and el.isWeapon:
					var res : WeaponRes= el.weaponInfo
					var ins = load(res.weaponNode).instance()
					$Weapon.add_child(ins)
					weapon=ins
					el.queue_free()
				#The thing is not a weapon
				else:
					AddItem(el)
	#Testing 
#	elif event.is_action_pressed("ui_accept"):
#		#Add coins
#		print(DepleteCoin(3))

func _physics_process(_delta):
	#DASHING
	match(dashState):
		#Normal
		dashStates.normal:
			if Input.is_action_just_pressed("dash") and GetInputDir()!=Vector2.ZERO and !isKnocked:
				emit_signal("playerDashed")
				dashState=dashStates.dashing
				$DashingTimer.start(dashTime)
		#Dashing
		dashStates.dashing:
			canReceiveDamage=false
		#Windup
		dashStates.windup:
			pass
	#Assign correct movement speed and direction
	if dashState!=dashStates.dashing:
		if isKnocked:
			#Movespeed when nocked
			moveSpeed=SPEED*0.6
		else:
			#Normally moving
			if !immobile:
				AssignSpriteDir()
				axis=GetInputDir()
				moveSpeed=SPEED*speedMod
				#Slow if attacking
				if attacking and weapon!=null:
					moveSpeed*=weapon.slow
	#Dashing
	else:
		moveSpeed=DASH*speedMod
		#Slow if attacking
		if attacking:
			moveSpeed*=weapon.slow
	#Movement
	Move(axis,moveSpeed)

#Movement
#Applied whenever you want the player to be knocked, you need to declare a directionof the knockback
func Knockback(direction):
	#Only be knocked back if isnt already knocked, dashing or cant be knocked back
	if !isKnocked and dashState!=dashStates.dashing and !unKnockable:
		emit_signal("playerKnocked")
		$KnockbackTimer.start()
		isKnocked=true
		axis=direction
func Move(direction,speed):
	movement=move_and_slide(direction*speed)
func AssignSpriteDir():
	var xDir = axis.x
	if xDir>0:
		$Sprite.flip_h=false
	elif xDir<0:
		$Sprite.flip_h=true
	#Walk animation
	if axis!=Vector2.ZERO:
		$AnimationPlayer.play("Walking")
	else:
		$AnimationPlayer.play("Idle")

#Gets the axis in a vector2 of the moving input
func GetInputDir():
	var ret = Vector2.ZERO
	ret.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	ret.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	ret.normalized()
	return ret

#Damage
#Damage player
func Damage(dam,direction):
	#Make sure player can receive damage
	if canReceiveDamage and notInvulnerable:
		health-=dam
		emit_signal("playerDamaged")
		Knockback(direction)
		$ReceiveDamageTimer.start()
func DamageWithoutKnockback(dam):
	#Make sure player can receive damage
	if canReceiveDamage and notInvulnerable:
		health-=dam
		emit_signal("playerDamaged")
		$ReceiveDamageTimer.start()

#Timers
#Received everytime dashing timer finishes
func DashingTimeout():
	match(dashState):
		#Dashing
		dashStates.dashing:
			canReceiveDamage=true
			dashState=dashStates.windup
			$DashingTimer.start(windupTime)
		#Windup
		dashStates.windup:
			dashState=dashStates.normal
#Finish knocback
func KnockbackTimerTimeout():
	isKnocked=false
#Player can be damaged again
func ReceiveDamageTimerTimeout():
	canReceiveDamage=true

#RANDOM FUNCTIONS
#Tries to add item to inventory and itemlist. Item is the item to add not the floor one
func AddItem(floorItem):
	if items.get_child_count()<inventorySize:
		var item = load(floorItem.itemInfo.item).instance()
		#Pick up
		items.add_child(item)
		inventory.AddItem(item)
		floorItem.queue_free()
#Call this whenever the health changes
func HealthChanged():
	healthSystem.HealthChanged(health)
#Call this when trying to use the currency system, it just redirects it to the correct node
func AddCoins(amount):
	currency.AddCoins(amount)
#Call this when trying to deplete coins, it just redirects
func DepleteCoin(amount) -> bool:
	return currency.DepleteCoin(amount)

#INFLUENCE
#Asked when anenemy tries to get inside area
func CanEnemyGoIn():
	if enemiesInsideInfluence<maxEnemiesInsideInfluence:
		return true
	else:
		return false
func BodyEnteredInfluence(body):
	enemiesInsideInfluence+=1
	body.insideInfluence=true
func BodyExitedInfluence(body):
	enemiesInsideInfluence-=1
	body.insideInfluence=false
