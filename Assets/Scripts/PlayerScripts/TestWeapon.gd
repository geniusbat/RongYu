extends Node2D

export(Resource) var res

var damage : int
var slow : float
var hitbox:Area2D
var player : KinematicBody2D
var vision : RayCast2D
var animationPlayer : AnimationPlayer
var shake : float
onready var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	hitbox=$Sprite/WeaponHitbox
	animationPlayer=$AnimationPlayer
	player=get_node("../..")
	vision=player.get_node("Vision")
	#Get data from resource
	if res.attack!=null:
		var _a = animationPlayer.add_animation("Attack",res.attack)
	self.damage=res.damage
	self.slow=res.movementSlow
	self.shake=res.screenShake
	$Sprite.texture=res.weaponSprite

func _process(_delta):
	#Detect hitbox and damage
	if animationPlayer.is_playing():
		var areas=hitbox.get_overlapping_areas()
		for el in areas:
			if PlayerCanSeeTarget(el):
				if el.get_parent().has_method("Damage"):
					el.get_parent().Damage(damage*player.damageMod,(-player.global_position+el.get_parent().global_position).normalized())
					#See if critical
					if rng.randi_range(0,100)<=player.critical+player.bonusCritical:
						player.emit_signal("criticalStrike",el)
				elif el.get_parent().has_method("Knockback"):
					el.get_parent().Knockback((-player.global_position+el.get_parent().global_position).normalized())
			elif el.get_parent().has_method("Bounce"):
				el.get_parent().Bounce(player.global_position)
	else:
		#Rotate towards mouse
		look_at(get_global_mouse_position())
		
func PlayerCanSeeTarget(enemy):
	vision.set_cast_to(player.to_local(enemy.global_position+Vector2(0,5)))
	vision.force_raycast_update()
	var col = vision.get_collider()
	if col!=null and col==enemy:
		return true
	else:
		return false

func Attack():
	if !animationPlayer.is_playing():
		player.emit_signal("playerAttacked")
		animationPlayer.play("Attack")

func ScreenShake():
	player.get_node("Camera").ScreenShake(shake)

func Finished():
	#Tell player he finished attacking
	player.attacking=false

func Drop():
	pass
