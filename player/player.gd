extends CharacterBody3D

@export var JUMP_VELOCITY: float = 12.0
@export var FRICTION: float = 5.0
@export var ACCELERATION: float = 4.0
@export var MAX_SPEED: float = 15.0

@export var mouse_sens: float = 0.1
@export var controller_sens: float = 2.5

const CAMERA_ANGLE_LIMIT: float = deg_to_rad(90)

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head: Node3D = $Head
var joy: Control
var jumpButton: Control

var is_controller: bool = false
var inverted: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	joy = get_node_or_null("../UI/Joystick")
	jumpButton = get_node_or_null("../UI/JumpButton")
	if OS.get_name() == "Android":
		if joy == null: return
		if jumpButton == null: return
		jumpButton.connect("btnJumpPressed",jumpPressed)
	if inverted:
		mouse_sens = -mouse_sens
		controller_sens = -controller_sens


func _unhandled_input(event: InputEvent) -> void:
	if OS.get_name() == "Android":
		if event is InputEventScreenDrag:
			is_controller = false
			var drag_motion: InputEventScreenDrag = event as InputEventScreenDrag
			if float(get_window().size.x)/2 < drag_motion.position.x:
				_rotate_camera(drag_motion.relative,mouse_sens)
	else:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			is_controller = false
			var mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
			_rotate_camera(mouse_motion.relative, mouse_sens)
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		is_controller = true


func _input(event) -> void:
	if event.is_action_pressed("pause"):
		var new_mouse_mode: int = (
			Input.MOUSE_MODE_CAPTURED
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE
			else Input.MOUSE_MODE_VISIBLE
		)
		Input.set_mouse_mode(new_mouse_mode)


func _physics_process(delta: float) -> void:
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
		
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jumpPressed()

	var input_dir: Vector2 = joy.axis_vector if (joy != null and joy.axis_vector != Vector2.ZERO)  else Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)
	if is_controller:
		var look_dir: Vector2 = Input.get_vector(
		"look_left", "look_right", "look_up", "look_down"
		)
		_rotate_camera(look_dir,controller_sens)
		
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var target_velocity: Vector3 = direction * MAX_SPEED
	var velocity_change: Vector3 = target_velocity - velocity
	velocity_change.y = 0

	var impulse: Vector3 = velocity_change * ACCELERATION * delta
	velocity += impulse

	velocity = velocity.lerp(Vector3.ZERO, FRICTION * delta)

	move_and_slide()

func _rotate_camera(motion: Vector2, sensitivity: float) -> void:
	rotate_y(deg_to_rad(-motion.x * sensitivity))
	head.rotate_x(deg_to_rad(-motion.y * sensitivity))
	head.rotation.x = clampf(head.rotation.x, -CAMERA_ANGLE_LIMIT, CAMERA_ANGLE_LIMIT)

func jumpPressed() -> void:
	velocity.y = JUMP_VELOCITY
