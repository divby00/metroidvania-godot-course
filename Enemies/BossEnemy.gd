extends "res://Enemies/Enemy.gd"

var main_instances = ResourceLoader.main_instances

const Bullet = preload("res://Enemies/EnemyBullet.tscn")
export(int) var ACCELERATION = 70

onready var left_wall_check = $LeftWallCheck
onready var right_wall_check = $RightWallCheck

signal died

func _ready():
	if SaverAndLoader.custom_data.boss_defeated:
		queue_free()

func _on_Timer_timeout():
	fire_bullet()

func _process(delta):
	chase_player(delta)
	
func chase_player(delta):
	var player = main_instances.player
	if player != null:
		var direction = sign(player.global_position.x - global_position.x)
		motion.x += ACCELERATION * delta * direction
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		global_position.x += motion.x * delta
		rotation_degrees = lerp(rotation_degrees, (motion.x / MAX_SPEED) * 10, .3)
		
		if (right_wall_check.is_colliding() and motion.x > 0) or (left_wall_check.is_colliding() and motion.x < 0):
			motion.x *= -0.5

func fire_bullet():
	var main = get_tree().current_scene
	var bullet = Bullet.instance()
	main.add_child(bullet)
	bullet.global_position = global_position
	var velocity = Vector2.DOWN * 50
	velocity = velocity.rotated(deg2rad(rand_range(-30, 30)))
	bullet.velocity = velocity

func _on_EnemyStats_enemy_died():
	emit_signal("died")
	SaverAndLoader.custom_data.boss_defeated = true
	._on_EnemyStats_enemy_died()
