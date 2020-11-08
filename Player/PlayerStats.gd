extends Resource

class_name PlayerStats

var max_health = 5
var health = max_health setget set_health

signal player_died
signal player_health_changed(value)

func set_health(value):
	if value < health:
		Events.emit_signal("add_screenshake", 0.5, 0.7)
	health = clamp(value, 0, max_health)
	emit_signal("player_health_changed", health)
	
	if health == 0:
		emit_signal("player_died")
