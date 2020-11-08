extends Node2D

var motion = Vector2(rand_range(-20, 20), rand_range(-20, 20))

func _process(delta):
	position += motion * delta
	
