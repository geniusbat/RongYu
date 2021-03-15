extends Node2D

var parent
var animationPlayer : AnimationPlayer
var hitbox : Area2D
onready var weaponSound = $WeaponSound
var prevAttack : String

func _ready():
	parent=get_node("../..")
	hitbox=$Sprite/Area2D
	animationPlayer=$AnimationPlayer
	prevAttack=""

func _process(_delta):
	if animationPlayer.is_playing():
		var areas=hitbox.get_overlapping_areas()
		for el in areas:
			if el.get_parent().has_method("Damage"):
				el.get_parent().Damage(parent.damage,(-parent.global_position+el.get_parent().global_position).normalized())

func Attack():
	match(prevAttack):
		"":
			animationPlayer.play("Attack00")
			prevAttack="Attack00"
		"Attack00":
			animationPlayer.play("Attack01")
			prevAttack="Attack01"
		"Attack01":
			animationPlayer.play("Attack02")
			prevAttack="Attack02"
		"Attack02":
			animationPlayer.play("Attack00")
			prevAttack="Attack00"

func Finish():
	parent.attacking=false

func SoundWeapon():
	weaponSound.play()
