extends Area2D
class_name Powerup

var player_stats = ResourceLoader.player_stats

func _pickup():
	SoundFx.play("Powerup", 1, -15)
