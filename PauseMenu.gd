
extends ColorRect

var paused = false setget set_paused

func _process(delta):
	var player_is_alive = get_tree().get_nodes_in_group("Player").size() > 0
	if Input.is_action_just_pressed("pause") and player_is_alive:
		self.paused = !self.paused

func _on_ResumeButton_pressed():
	SoundFx.play("Click", 1, -10)
	self.paused = false

func _on_QuitButton_pressed():
	get_tree().quit(0)
	
func set_paused(value):
	paused = value
	get_tree().paused = paused
	visible = paused
	if paused:
		SoundFx.play("Pause", 1, -10)
	else:
		SoundFx.play("Unpause", 1, -10)
