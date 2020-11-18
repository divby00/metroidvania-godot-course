extends StaticBody2D

onready var animation_player = $AnimationPlayer

func _on_SaveArea_body_entered(body):
	animation_player.play("Save")
	SaverAndLoader.save_game()
