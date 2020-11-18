extends Resource

class_name PlayerStats

var max_health = 5
var max_missiles = 5
var health = max_health setget set_health
var missiles = max_missiles setget set_missiles
var missiles_unlocked = false setget set_missiles_unlocked

signal player_died
signal player_missiles_unlocked(value)
signal player_missiles_changed(value)
signal player_health_changed(value)

func set_health(value):
	if value < health:
		Events.emit_signal("add_screenshake", 0.5, 0.7)
	health = clamp(value, 0, max_health)
	emit_signal("player_health_changed", health)
	
	if health == 0:
		emit_signal("player_died")

func set_missiles(value):
	missiles = clamp(value, 0, max_missiles)
	emit_signal("player_missiles_changed", missiles)

func set_missiles_unlocked(value):
	missiles_unlocked = value
	emit_signal("player_missiles_unlocked", missiles_unlocked)
