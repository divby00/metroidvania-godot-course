extends Node

export(float) var volumne = 1
export(float) var pitch = 1
export(String) var sound_stream = ""

func _ready():
	if sound_stream != "":
		SoundFx.play(sound_stream)
