extends Powerup


func _pickup():
	player_stats.missiles_unlocked = true
	queue_free()
