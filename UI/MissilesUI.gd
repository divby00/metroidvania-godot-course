extends HBoxContainer

var player_stats = ResourceLoader.player_stats

onready var label = $Label

func _ready():
	player_stats.connect("player_missiles_changed", self, "_on_player_missiles_changed")
	player_stats.connect("player_missiles_unlocked", self, "_on_player_missiles_unlocked")

func _on_player_missiles_changed(value):
	label.text = str(value)

func _on_player_missiles_unlocked(value):
	visible = value
