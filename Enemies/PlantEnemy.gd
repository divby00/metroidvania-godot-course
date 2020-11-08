extends "res://Enemies/Enemy.gd"

const EnemyBullet = preload("res://Enemies/EnemyBullet.tscn")

export (int) var BULLET_SPEED = 30
export (float) var SPREAD = 20

onready var fire_direction = $FireDirection
onready var bullet_spawn = $BulletSpawnPoint

func fire_bullet():
	var velocity = ((fire_direction.global_position - global_position).normalized()) * BULLET_SPEED
	velocity = velocity.rotated(deg2rad(rand_range(-SPREAD, SPREAD)))
	var main = get_tree().current_scene
	var bullet = EnemyBullet.instance()
	main.add_child(bullet)
	bullet.global_position = bullet_spawn.global_position
	bullet.velocity = velocity

