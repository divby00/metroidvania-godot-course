extends "res://Player/Projectile.gd"

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
const brick_layer_bit = 4

func _on_Hitbox_body_entered(body):
	if body.get_collision_layer_bit(brick_layer_bit):
		body.queue_free()
		Utils.instance_scene_on_main(EnemyDeathEffect, global_position + Vector2(-10, -10))
	._on_Hitbox_body_entered(body)
