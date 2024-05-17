extends CharacterBody3D

@export var check_points:Array[Marker3D]
@export var clearing_check_points:Array[Marker3D]
@export var player: CharacterBody3D

@export var top_mound_marker: Marker3D


@export var sitting_log: Node3D

var use_check_points: Array[Marker3D]

var target_position: Vector3 #set this to the target coordinate
var speed: float = 1.0

var check_index:int = 0

var walking: = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var anim_tree = %AnimationTree

var turn_value :float = 0
var sitting_value: float = 0
var sit_down_value: float = 0
var standing_value: float = 0

var can_turn: bool = true

enum {WALK, TURN, SITDOWN, SITTING, STANDING}

var curr_anim = WALK

var blend_speed :float = 2.0
var blend_speed_two :float = 2.0

var to_mound: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignals.dad_to_mound.connect(_dad_to_mound)
	GlobalSignals.dad_to_clearing.connect(_dad_to_clearing)
	GlobalSignals.start_clearing.connect(_start_clearing)
	GlobalSignals.dad_repeat_log.connect(_dad_repeat_log)
	use_check_points = check_points
	$AnimationPlayer.play("mixamo_com")
	$AnimationPlayer.pause()
	get_tree().create_timer(4.0).timeout
	_next_position()
	_update_tree()
	#GlobalSignals.emit_signal("dad_to_mound")

func _start_clearing():
	walking = false
	global_position = sitting_log.global_position
	global_position.y -= 0.2
	_sit_down()
	

func _dad_to_mound():
	walking = false
	curr_anim = STANDING
	to_mound = false
	global_position = top_mound_marker.global_position
	rotation_degrees.y = 0.0


func _dad_to_clearing():
	_dad_repeat_log(false)
	use_check_points = clearing_check_points
	_next_position()	

func _dad_repeat_log(state):
	if state:
		%RepeatLogTimer.start()
	else:
		%RepeatLogTimer.stop()

func _update_tree():
	anim_tree["parameters/BlendTurn/blend_amount"] = turn_value
	anim_tree["parameters/SitDown/blend_amount"] = sit_down_value
	anim_tree["parameters/Sitting/blend_amount"] = sitting_value
	anim_tree["parameters/StandingIdle/blend_amount"] = standing_value
	
func _handle_animation(delta):
	match curr_anim:
		
		WALK:
			turn_value = lerp(turn_value, 0.0, blend_speed_two*delta)
			sit_down_value = lerp(sit_down_value, 0.0, blend_speed*delta)
			sitting_value = lerp(sitting_value, 0.0, blend_speed*delta)
			standing_value = lerp(standing_value, 0.0, blend_speed*delta)
			_update_tree()
		TURN:
			turn_value = lerp(turn_value, 1.0, blend_speed*delta)
			sit_down_value = lerp(sit_down_value, 0.0, blend_speed*delta)
			sitting_value = lerp(sitting_value, 0.0, blend_speed*delta)
			standing_value = lerp(standing_value, 0.0, blend_speed*delta)
			_update_tree()
		SITDOWN:
			sit_down_value = lerp(sit_down_value, 1.0, blend_speed*delta)
			turn_value = lerp(turn_value, 0.0, blend_speed*delta)
			sitting_value = lerp(sitting_value, 0.0, blend_speed*delta)
			standing_value = lerp(standing_value, 0.0, blend_speed*delta)
			_update_tree()
		SITTING:
			sit_down_value = lerp(sit_down_value, 0.0, blend_speed*delta)
			turn_value = lerp(turn_value, 0.0, blend_speed*delta)
			sitting_value = lerp(sitting_value, 1.0, blend_speed*delta)
			standing_value = lerp(standing_value, 0.0, blend_speed*delta)
			_update_tree()
		STANDING:
			standing_value = lerp(standing_value, 1.0, blend_speed*delta)
			sit_down_value = lerp(sit_down_value, 0.0, blend_speed*delta)
			turn_value = lerp(turn_value, 0.0, blend_speed*delta)
			sitting_value = lerp(sitting_value, 0.0, blend_speed*delta)
			_update_tree()
			
func _physics_process(delta: float) -> void:
	
	_handle_animation(delta)
	

	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if walking:
		var direction = global_position.direction_to(target_position)
		

		if global_position.distance_to(target_position) > 1.0:
			var player_dist: float = global_position.distance_to(player.global_position)
			if player_dist < 7.0:
				if not can_turn:
					$WalkTimer.start()
					
				#print ("walking")
				rotation.y=lerp_angle(rotation.y,atan2(velocity.x,velocity.z),.1)
				speed = lerp(speed, 4.0, 0.5)
				velocity = direction * speed
				curr_anim = WALK
				GlobalSignals.emit_signal("hide_speech")
				$SpeechTimer.stop()
				if not is_on_floor():
					velocity.y -= gravity * delta
				move_and_slide()
			else:
				if can_turn:
					#print ("turn")
					can_turn = false
					curr_anim = TURN
					$SpeechTimer.start()
					speed = lerp(speed, 0.0, 1.0)
					velocity = direction * speed
					if not is_on_floor():
						velocity.y -= gravity * delta
					move_and_slide()
					#$AnimationPlayer.play("turn")
		else:
			#$AnimationPlayer.pause()
			#$AnimationPlayer2.play("mixamo_com")
			walking = false
			_next_position()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("sit"):
		walking = false
		var tween = create_tween()
		tween.tween_property(self, "rotation_degrees:y", 90.0, 1.0)
		#rotation_degrees.y = lerp(rotation_degrees.y, rotation_degrees.y+90.0, 0.2)
		
		curr_anim = SITTING

func _sit_down():
	walking = false
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:y", 270.0, 1.0)
	$SpeechTimer.stop()
	GlobalSignals.emit_signal("hide_speech")
	#rotation_degrees.y = lerp(rotation_degrees.y, rotation_degrees.y+90.0, 0.2)
	curr_anim = SITTING

func _next_position():
	if check_index < use_check_points.size():
		target_position = use_check_points[check_index].global_position
		#get_tree().create_timer(0.2).timeout
		walking = true
		$SpeechTimer.stop()
		GlobalSignals.emit_signal("hide_speech")
		curr_anim = WALK
		#$AnimationPlayer.play("mixamo_com")
		print (use_check_points[check_index].name)
		_check_for_narration(use_check_points[check_index].name)
		check_index += 1
	else:
		check_index = 0
		if to_mound:
			to_mound = false
			GlobalSignals.emit_signal("dad_to_mound")
		else:
			_sit_down()
			await get_tree().create_timer(3.0).timeout
			GlobalSignals.emit_signal("show_speech", "Saif, find me 3 sticks. I want to show you something.")

func _check_for_narration(check_point: String):
	match check_point:
		"Check10":
			GlobalSignals.emit_signal("show_narration", "My dad was the only one who called me Saif instead of Saiful.")
		"Check15":
			GlobalSignals.emit_signal("show_narration", "My dad always liked to take me on long walks through the forest...")
		"Check18":
			GlobalSignals.emit_signal("show_narration", "but that day we went further than we had ever been before.")
		"Check23":
			GlobalSignals.emit_signal("change_dad_max_dist", 18.5)
		"CheckEnd":
			GlobalSignals.emit_signal("show_narration", "For a second I panicked when I lost sight of my dad.")


func _on_walk_timer_timeout() -> void:
	can_turn = true




func _on_speech_timer_timeout() -> void:
	GlobalSignals.emit_signal("show_speech", "Come on Saif, keep up!")


func _on_repeat_log_timer_timeout() -> void:
	GlobalSignals.emit_signal("log_emit")
	GlobalSignals.emit_signal("show_speech", "Come on Saif, drag that log over and use it to climb up.")
