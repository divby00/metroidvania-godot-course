extends "res://Levels/Level.gd"

const PLAYER_BIT = 0
onready var block_door = $BlockDoor

func set_block_door(active):
	block_door.visible = active
	block_door.set_collision_mask_bit(PLAYER_BIT, active)

func _on_Trigger_area_triggered():
	if not SaverAndLoader.custom_data.boss_defeated:
		set_block_door(true)
	else:
		set_block_door(false)

func _on_BossEnemy_died():
	set_block_door(false)
