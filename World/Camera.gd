extends Camera2D

var shake = 0
var main_instances = ResourceLoader.main_instances

onready var timer = $Timer


func _ready():
	Events.connect("add_screenshake", self, "_on_Events_add_screenshake")
	main_instances.world_camera = self
	
func _exit_tree():
	main_instances.world_camera = null
	
func _process(delta):
	offset_h = rand_range(-shake, shake)
	offset_v = rand_range(-shake, shake)
	
func screenshake(amount, duration):
	shake = amount
	timer.wait_time = duration
	timer.start()

func _on_Timer_timeout():
	shake = 0

func _on_Events_add_screenshake(amount, duration):
	screenshake(amount, duration)
