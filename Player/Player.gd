extends KinematicBody2D

const DustEffect = preload("res://Effects/DustEffect.tscn")
const PlayerBullet = preload("res://Player/PlayerBullet.tscn")
const PlayerMissile = preload("res://Player/PlayerMissile.tscn")
const WallSlideEffect = preload("res://Effects/WallSlideEffect.tscn")
const JumpEffect = preload("res://Effects/JumpEffect.tscn")

var player_stats = ResourceLoader.player_stats
var main_instances = ResourceLoader.main_instances

export (int) var ACCELERATION = 512
export (int) var MAX_SPEED = 64
export (float) var FRICTION = 0.25
export (int) var GRAVITY = 200
export (int) var JUMP_FORCE = 128
export (int) var MAX_SLOPE_ANGLE = 46
export (int) var BULLET_SPEED = 250
export (int) var MISSILE_SPEED = 150
export (int) var WALL_SLIDE_SPEED = 48
export (int) var MAX_WALL_SLIDE_SPEED = 128
export (bool) var INVINCIBLE = false setget set_invincible

enum {
	MOVE,
	WALL_SLIDE
}

var state = MOVE
var motion = Vector2.ZERO
var snap_vector = Vector2.ZERO
var just_jumped = false
var double_jump = true

onready var sprite = $Sprite
onready var sprite_animator = $SpriteAnimator
onready var coyote_jump_timer = $CoyoteJumpTimer
onready var gun = $Sprite/PlayerGun
onready var muzzle = $Sprite/PlayerGun/Sprite/Muzzle
onready var fire_bullet_timer = $FireBulletTimer
onready var blink_animator = $BlinkAnimator
onready var powerup_detector = $PowerupDetector
onready var camera_follow = $CameraFollow

signal hit_door(door)

func _ready():
	player_stats.connect("player_died", self, "_on_died")
	player_stats.missiles_unlocked = SaverAndLoader.custom_data.missiles_unlocked
	main_instances.player = self
	call_deferred("assign_world_camera")

func queue_free():
	.queue_free()
	main_instances.player = null

func set_invincible(value):
	INVINCIBLE = value

func _physics_process(delta):
	just_jumped = false
	
	match state:
		MOVE:
			var input_vector = get_input_vector()
			apply_horizontal_force(input_vector, delta)
			apply_friction(input_vector)
			update_snap_vector()
			jump_check()
			apply_gravity(delta)
			update_animations(input_vector)
			move()
			wall_slide_check()
			
		WALL_SLIDE:
			sprite_animator.play("WallSlide")
			var wall_axis = get_wall_axis()
			if wall_axis != 0:
				sprite.scale.x = wall_axis
			wall_slide_jump_check(wall_axis)
			wall_slide_drop(delta)
			move()
			wall_detach(delta, wall_axis)
	
	if Input.is_action_pressed("fire") and fire_bullet_timer.time_left == 0:
		fire_bullet()

	if Input.is_action_pressed("fire_missile") and fire_bullet_timer.time_left == 0:
		if player_stats.missiles > 0 and player_stats.missiles_unlocked:
			fire_missile()

func assign_world_camera():
	camera_follow.remote_path = main_instances.world_camera.get_path()

func save():
	var save_dictionary = {
		"filename": get_filename(),
		"parent": get_parent().get_path(),
		"position_x": position.x,
		"position_y": position.y
	}
	return save_dictionary

func fire_bullet():
	SoundFx.play("Bullet", rand_range(0.8, 1.1))
	# This is not working for some unknown reason
	#var bullet = Utils.instance_scene_on_main(PlayerBullet, muzzle.global_position)
	var bullet = PlayerBullet.instance()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.velocity = Vector2.RIGHT.rotated(gun.rotation) * BULLET_SPEED
	bullet.velocity.x *= sprite.scale.x
	bullet.rotation = bullet.velocity.angle()
	fire_bullet_timer.start()


func fire_missile():
	SoundFx.play("Explosion", rand_range(0.8, 1.1))
	var missile = PlayerMissile.instance()
	get_tree().current_scene.add_child(missile)
	missile.global_position = muzzle.global_position
	missile.velocity = Vector2.RIGHT.rotated(gun.rotation) * MISSILE_SPEED
	missile.velocity.x *= sprite.scale.x
	motion -= missile.velocity * .25
	missile.rotation = missile.velocity.angle()
	fire_bullet_timer.start()
	player_stats.missiles -= 1

func get_input_vector():
	var input_vector = Vector2.ZERO
	# Original way to determine whether the direction is positive or negative based on the key presses
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	return input_vector

func apply_horizontal_force(input_vector, delta):
	if input_vector != Vector2.ZERO:
		motion.x += input_vector.x * ACCELERATION * delta
		# clamp returns motion.x if motion.x is between -MAX_SPEED and MAX_SPEED, otherwise it returns
		# the closest value among -MAX_SPEED and MAX_SPEED
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)

func apply_friction(input_vector):
	if input_vector == Vector2.ZERO && is_on_floor():
		motion.x = lerp(motion.x, 0, FRICTION)

func update_snap_vector():
	if is_on_floor():
		snap_vector = Vector2.DOWN

func jump_check():
	if is_on_floor() or coyote_jump_timer.time_left > 0:
		if Input.is_action_just_pressed("ui_up"):
			jump(JUMP_FORCE)
			just_jumped = true
	else:
		# Cool way to implement a variable jump height based on the duration of the jump key press
		if Input.is_action_just_released("ui_up") and motion.y < -JUMP_FORCE / 2:
			motion.y = -JUMP_FORCE / 2
		if Input.is_action_just_pressed("ui_up") and double_jump == true:
			jump(JUMP_FORCE * .75)
			double_jump = false

func jump(force):
	SoundFx.play("Jump", rand_range(0.8, 1.0), -5)
	Utils.instance_scene_on_main(JumpEffect, global_position)
	motion.y = -force
	snap_vector = Vector2.ZERO

func apply_gravity(delta):
	if !is_on_floor():
		motion.y += GRAVITY * delta
		motion.y = min(motion.y, JUMP_FORCE)

func update_animations(input_vector):
	# sign returns -1 if number is negative, +1 if number is positive and zero if number is 0
	var facing = sign(get_local_mouse_position().x)
	if facing != 0:
		sprite.scale.x = facing
	
	if input_vector.x != 0:
		sprite_animator.play("Run")
		# flip the animation based on the player facing position and the mouse position
		# (looks like the player is walking backwards)
		sprite_animator.playback_speed = input_vector.x * sprite.scale.x
	else:
		sprite_animator.play("Idle")
		sprite_animator.playback_speed = 1
	
	if not is_on_floor():
		sprite_animator.play("Jump")

func move():
	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	var last_position = position
	var last_motion = motion
	motion = move_and_slide_with_snap(motion, snap_vector * 4, Vector2.UP, true, 4, deg2rad(MAX_SLOPE_ANGLE))
	
	#Landing
	if was_in_air and is_on_floor():
		motion.x = last_motion.x
		double_jump = true
		Utils.instance_scene_on_main(JumpEffect, global_position)
	
	# We've just left the ground
	if was_on_floor and not is_on_floor() and not just_jumped:
		motion.y = 0
		position.y = last_position.y
		# Start coyote jump timer
		coyote_jump_timer.start()
	 
	# Prevent sliding
	if is_on_floor() and get_floor_velocity().length() == 0 and abs(motion.x) < 1:
		position.x = last_position.x

func create_dust_effect():
	SoundFx.play("Step", rand_range(.6, 1.2), -10)
	var dust_position = global_position
	dust_position.x += rand_range(-4, 4)
	Utils.instance_scene_on_main(DustEffect, dust_position)

func wall_slide_check():
	if not is_on_floor() and is_on_wall():
		state = WALL_SLIDE
		double_jump = true
		#create_dust_effect()

# This function will check for a wall at the left and the right, and it's going
# to create a number that is -1 if there's a wall at the left, 1 if it is at the
# right or zero if there's no wall
func get_wall_axis():
	var is_right_wall = test_move(transform, Vector2.RIGHT) # This returns true if there's a collision at the right
	var is_left_wall  = test_move(transform, Vector2.LEFT) # This returns true if there's a collision at the left
	return int(is_left_wall) - int(is_right_wall)
	
func wall_slide_jump_check(wall_axis):
	if Input.is_action_just_pressed("ui_up"):
		SoundFx.play("Jump", rand_range(0.8, 1.0), -5)
		motion.x = wall_axis * MAX_SPEED
		motion.y = -JUMP_FORCE / 1.25
		state = MOVE
		var dust_position = global_position + Vector2(wall_axis * 4, -4)
		var main = get_tree().current_scene
		var dust = WallSlideEffect.instance()
		main.add_child(dust)
		dust.global_position = dust_position
		dust.scale.x = wall_axis

func wall_slide_drop(delta):
	var slide_speed = WALL_SLIDE_SPEED
	if Input.is_action_pressed("ui_down"):
		slide_speed = MAX_WALL_SLIDE_SPEED
	motion.y = min(motion.y + GRAVITY * delta, slide_speed)

func wall_detach(delta, wall_axis):
	if Input.is_action_just_pressed("ui_right"):
		motion.x = ACCELERATION * delta
		state = MOVE
	if Input.is_action_just_pressed("ui_left"):
		motion.x = -ACCELERATION * delta
		state = MOVE	
	if wall_axis == 0 or is_on_floor():
		state = MOVE

func _on_Hurtbox_hit(damage):
	if not INVINCIBLE:
		SoundFx.play("Hurt")
		player_stats.health -= damage
		blink_animator.play("Blink")

func _on_died():
	queue_free()

func _on_PowerupDetector_area_entered(area):
	if area is Powerup:
		area._pickup()
