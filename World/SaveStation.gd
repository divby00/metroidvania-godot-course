extends StaticBody2D


var player_stats = ResourceLoader.player_stats

onready var animation_player = $AnimationPlayer

func _on_SaveArea_body_entered(_body):
	animation_player.play("Save")
	SaverAndLoader.save_game()
	player_stats.refill_stats()
	SoundFx.play("Powerup", .6, -10)
