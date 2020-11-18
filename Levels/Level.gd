extends Node2D

const World = preload("res://World.gd")

func _ready():
	var parent = get_parent()
	if parent is World:
		parent.current_level = self

func save():
	var save_dictionary = {
		"filename": get_filename(),
		"parent": get_parent().get_path(),
		"position_x": position.x,
		"position_y": position.y
	}
	return save_dictionary

