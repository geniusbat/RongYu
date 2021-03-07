extends KinematicBody2D

export(float) var speed = 100
export(int) var health = 2
export(int) var chanceToSpawnItem = 50

var dir : Vector2
onready var knockbackTimer = $KnockbackTimer
onready var isKnocked = false
onready var fallen = false
onready var particles = preload("res://Objects/Misc/Particles/BoxParticles.tscn")
onready var randomItem = preload("res://Objects/Items/RandomFloorItem.tscn")
onready var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()


func _physics_process(_delta):
	if isKnocked:
		var _a = move_and_slide(dir*speed)
	elif fallen:
		var _a = move_and_slide(Vector2.DOWN*speed)

func Damage(damage,direction):
	dir = direction
	if !isKnocked:
		health -= damage
		if health>0:
			Knockback(direction)
		else:
			var ins = particles.instance()
			ins.global_position=global_position
			get_parent().add_child(ins)
			SpawnItem()
			queue_free()
func SpawnItem():
	var num = rng.randi_range(0,100)
	if num<=chanceToSpawnItem:
		var ins = randomItem.instance()
		ins.position=position
		get_parent().add_child(ins)

func Fall():
	fallen = true
	if has_node("CollisionShape2D") and global_position.y < 0:
#		z_as_relative=false
#		z_index=-40
		$Sprite.z_as_relative=false
		$Sprite.z_index=-40

func Knockback(_direction):
	if !isKnocked:
		isKnocked=true
		knockbackTimer.start()

func _on_KnockbackTimer_timeout():
	isKnocked=false
