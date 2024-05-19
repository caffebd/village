extends CharacterBody3D


var  walk_speed:float = 0.75

const JUMP_VELOCITY:float = 2.5
#const SENSITIVITY:float = 0.003
const SENSITIVITY:float = 0.0008



@export var attack_marker: Marker3D
@export var rotate_marker: Marker3D
@export var lunge_marker: Marker3D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed = 2.0

const BASE_FOV = 70.0
const FOV_CHANGE = 1.5

var constant_wobble:bool = false

#@onready var head = %Head
@onready var camera = %PlayerCam
@onready var ray: RayCast3D = %PlayerRay
@onready var player_hand = %Hand
@onready var head = %Head
@onready var hud = %Hud

@export var father: CharacterBody3D


@export var wobble_head:bool = true

@export var start_mound_marker: Marker3D
@export var start_clearing_marker: Marker3D

@export var throwForce = 0.3
@export var followSpeed = 10.0
@export var followDistance = 0.8
@export var maxDistanceFromCamera = 5.0

var use_cursor: bool = false

var too_far: bool = false

var max_dad_dist: float = 9.0

#head wobble settings here

#3
#0.05

var BOB_FREQ = 3.0
var BOB_AMP = 0.05
var t_bob = 0.0

var lean_amount = 1.5
var lean_weight = 0.05

var can_warp: bool = true

var heldObject: RigidBody3D

var joy_rotate_x : float = 0.0
var joy_rotate_y : float = 0.0

var last_distance: float = 0.0

var following_dad: bool = false

var can_trigger_orb: bool = false

#end head wobble settings

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GlobalSignals.start_clearing.connect(_start_clearing)
	GlobalSignals.change_dad_max_dist.connect(_change_dad_max_dist)
	GlobalSignals.clearing_trigger_orb.connect(_clearing_trigger_orb)
	#GlobalSignals.dad_to_mound.connect(_start_mound)
	head.rotation_degrees.y = 0.0
	last_distance = global_position.distance_to(father.global_position)
	

func _start_mound():
	global_position = start_mound_marker.global_position

func _start_clearing():
	global_position = start_clearing_marker.global_position

func _clearing_trigger_orb():
	can_trigger_orb = true
							
func _input(event):
	if event is InputEventMouseMotion:
		if use_cursor:
			return
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60)) 
	
	_controller_support()
	
	if Input.is_action_just_pressed("ui_cancel"):
		if use_cursor:
			use_cursor = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			use_cursor = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("torch"):
		%SpotLight3D.visible = !%SpotLight3D.visible


func _controller_support():
	
	if Input.is_action_pressed("joy_left"):
		joy_rotate_x = 10.0
	if Input.is_action_just_released("joy_left"):
		joy_rotate_x = 0.0
	if Input.is_action_pressed("joy_right"):
		joy_rotate_x = -10.0
	if Input.is_action_just_released("joy_right"):
		joy_rotate_x = 0.0

	if Input.is_action_pressed("joy_up"):
		joy_rotate_y = 10.0
	if Input.is_action_just_released("joy_up"):
		joy_rotate_y = 0.0
	if Input.is_action_pressed("joy_down"):
		joy_rotate_y = -10.0
	if Input.is_action_just_released("joy_down"):
		joy_rotate_y = 0.0	
	
func _take_action():
	var collider = ray.get_collider()
	if collider != null:
		print ("clicked")

func _change_dad_max_dist(dist):
	max_dad_dist = dist

func _physics_process(delta):
	# Add the gravity.
	
	if following_dad:
	
		var dist = global_position.distance_to(father.global_position)
		#print (dist)
		if dist > max_dad_dist:
			if not too_far:
				GlobalSignals.emit_signal("show_narration", "I didn't want to go too far from dad.")
			too_far = true
			speed = 0.75
			if dist > max_dad_dist + 1:
				speed = 0.25
			if dist < last_distance:
				speed = 1.5
		else:
			speed = 2.0
			too_far = false
		
		
		last_distance = dist
	
	handle_holding_objects()
	
	_hud_target()
	
	head.rotate_y(joy_rotate_x * SENSITIVITY)
	camera.rotate_x(joy_rotate_y * SENSITIVITY)
	if joy_rotate_y != 0:
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
	
	if not is_on_floor():
		velocity.y -= gravity * delta



	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * 2.0
	var query = PhysicsRayQueryParameters3D.create(origin, end)

	var result = space_state.intersect_ray(query)
	
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("use"):
		var collider = ray.get_collider()
		if collider != null:

			if collider.get_parent().is_in_group("log"):
				var object = collider.get_parent()
				object.dragged(attack_marker)
				#object.global_position.z = attack_marker.global_position.z
				#object.global_position.x = attack_marker.global_position.x
	
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			#velocity.x = direction.x * speed
			#velocity.z = direction.z * speed
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)


	if wobble_head:
		if input_dir.x>0:
			head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(-lean_amount), lean_weight)
		elif input_dir.x<0:
			head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(lean_amount), lean_weight)
		else:
			head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(0), lean_weight)
		
		if not constant_wobble:	
			t_bob += delta * velocity.length() * float(is_on_floor())
			camera.transform.origin =_headbob(t_bob)

	if constant_wobble:
		t_bob += delta * 2.0 * float(is_on_floor())
		camera.transform.origin =_headbob(t_bob)


	move_and_slide()


func _hud_target():
	var collider = ray.get_collider()
	if collider != null:
		if collider.is_in_group("highlight"):
			hud.target.modulate = Color(1,1,1,1)
		else:
			hud.target.modulate = Color(1,1,1,0.2)
		print (collider.name)
		if collider.is_in_group("orb"):
			collider.orb_collider.set_deferred("disabled", true)
			can_trigger_orb = false
			GlobalSignals.emit_signal("show_narration", "While I was looking, I saw something glowing.")
			await get_tree().create_timer(5.0).timeout
			collider.sense_player = true
	else:
		hud.target.modulate = Color(1,1,1,0.2)	
func set_held_object(body):
	if body is RigidBody3D:
		if body.is_in_group("pick_item"):
			heldObject = body
			heldObject.held = true
	
func drop_held_object():
	heldObject = null
	
func throw_held_object():
	var obj = heldObject
	heldObject.held = false
	drop_held_object()
	obj.apply_central_impulse(-camera.global_basis.z * throwForce * 10)
	
func handle_holding_objects():
	# Throwing Objects
	if Input.is_action_just_pressed("throw"):
		if heldObject != null: throw_held_object()
		
	# Dropping Objects
	if Input.is_action_just_pressed("use"):
		if heldObject != null: drop_held_object()
		elif ray.is_colliding(): set_held_object(ray.get_collider())
		
	# Object Following
	if heldObject != null:
		var targetPos = camera.global_transform.origin + (camera.global_basis * Vector3(0.25, -0.25, -followDistance)) # 2.5 units in front of camera
		#var targetPos = %HoldPosition.global_transform.origin
		var objectPos = heldObject.global_transform.origin # Held object position
		
		heldObject.linear_velocity = (targetPos - objectPos) * followSpeed # Our desired position
		heldObject.rotation_degrees.z = 90.0
		# Drop the object if it's too far away from the camera
		if heldObject.global_position.distance_to(camera.global_position) > maxDistanceFromCamera:
			drop_held_object()
			
		# Drop the object if the player is standing on it (must enable dropBelowPlayer and set a groundRay/RayCast3D below the player)
		#if dropBelowPlayer && groundRay.is_colliding():
			#if groundRay.get_collider() == heldObject: drop_held_object()

func _headbob(time)->Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ/ 2) * BOB_AMP
	return pos

func _to_menu():
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")

