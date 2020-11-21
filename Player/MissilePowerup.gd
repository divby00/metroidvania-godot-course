extends Powerup


func _ready():
	if SaverAndLoader.custom_data.missiles_unlocked:
		queue_free()

func _pickup():
	._pickup()
	player_stats.missiles_unlocked = true
	queue_free()
