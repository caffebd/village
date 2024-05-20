extends CharacterBody3D

@export var clearing_markers: Array[Marker3D]
@export var path_one_markers: Array[Marker3D]

@export var player: CharacterBody3D

@onready var orb_collider: CollisionShape3D = %OrbCollider

var use_check_points: Array[Marker3D]

enum {CLEARING, PATHONE}

var  speed = 10.0

var intro_orb_speech: bool = false

var target_position: Vector3

var check_index:int = 0#

var moving: bool = false

var sense_player: bool = false

var start_speed = 30.0


func _ready() -> void:
	GlobalSignals.clearing_trigger_orb.connect(_clearing_trigger_orb)
	GlobalSignals.orb_sense_player.connect(_orb_sense_player)
	GlobalSignals.orb_next_position.connect(_orb_next_position)
	GlobalSignals.night_path_set_up.connect(_night_path_set_up)
	_set_check_points(CLEARING)
	await get_tree().create_timer(3.0).timeout
	moving = false
	$OrbHover.play("hover")


func _clearing_trigger_orb():
	speed = start_speed
	moving = true
	check_index = -1
	_next_position()
	#var tween = create_tween()
	#tween.tween_property(self, "global_position:y", 9.4, 5.0)


func _night_path_set_up():
	moving = false
	global_position = clearing_markers[clearing_markers.size()-1].global_position
	_set_check_points(PATHONE)
	check_index = -1
	sense_player = true

func _orb_sense_player(state):
	sense_player = state

func _orb_next_position():
	_next_position()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	
	var player_dist: float = global_position.distance_to(player.global_position)
	#print (player_dist)
	if player_dist < 4.0 and sense_player:
		sense_player = false
		_next_position()
		%SenseTimer.start()
	
	if not moving: return

	var direction = global_position.direction_to(target_position)
	if global_position.distance_to(target_position) > 0.2:
		rotation.y=lerp_angle(rotation.y,atan2(velocity.x,velocity.z),.1)
		#speed = lerp(10, speed, 0.5)
		if speed > 2:
			speed *= 0.8
		velocity = direction * speed
	else:
		moving = false

	move_and_slide()



func _set_check_points(phase):
	match phase:
		CLEARING:
			use_check_points = clearing_markers
		PATHONE:
			use_check_points = path_one_markers
	


func _next_position():
	check_index += 1
	if check_index < use_check_points.size():
		target_position = use_check_points[check_index].global_position
		speed = start_speed
		moving = true
		print ("select next")
	else:
		print ("select done")
		moving = false


func _on_sense_timer_timeout() -> void:
	sense_player = true
