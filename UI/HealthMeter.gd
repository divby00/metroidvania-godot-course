extends Control

var player_stats = ResourceLoader.player_stats

onready var full = $Full

func _ready():
	player_stats.connect("player_health_changed", self, "_on_player_health_changed")
	
func _on_player_health_changed(value):
	full.rect_size.x = value * 5 + 1 # w pixels of texture
