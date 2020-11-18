extends Node

onready var current_level = $Level_00
var main_instances = ResourceLoader.main_instances

func _ready():
	VisualServer.set_default_clear_color(Color.black)
	if SaverAndLoader.is_loading:
		SaverAndLoader.load_game()
		SaverAndLoader.is_loading = false
	main_instances.player.connect("hit_door", self, "_on_player_hit_door")
	
	
func _on_player_hit_door(door):
	# Wait until everything else in this processing tick is processed before calling this function
	call_deferred("change_levels", door)
	
func change_levels(door):
	var offset = current_level.position
	current_level.queue_free()
	var NewLevel = load(door.new_level_path)
	var new_level = NewLevel.instance()
	add_child(new_level)
	var new_door = get_door_with_connection(door, door.connection)
	var exit_position = new_door.position - offset
	new_level.position = door.position - exit_position
	
func get_door_with_connection(not_door, connection):
	var doors = get_tree().get_nodes_in_group("door")
	for door in doors:
		if door.connection == connection and door != not_door:
			return door
	return null
	
