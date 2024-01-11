extends CharacterBody3D

const JUMP_VELOCITY: float = 4.5
const AIR_ACCELERATION: float = 3.0
const MOUSE_SENSITIVITY: float = 0.01
const CONTROLLER_SENSITIVITY: float = 0.05
const WALK_SPEED: float = 5.0
const RUN_SPEED: float = 8.0
var speed: float = WALK_SPEED

const CAMERA_ANGLE_LIMIT: float = deg_to_rad(90)
const RUN_ACTIVATION_THRESHOLD: float = -1.5

const BOB_FREQUENCY: float = 2.0
const BOB_AMPLITUDE: float = 0.05
var bob_timer: float = 0.0

const BASE_FOV: float = 75.0
const FOV_CHANGE: float = 1.5

var gravity: float = 9.8

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/View

var is_player_running: bool = false
var is_controller: bool = false
var inverted_mouse: bool = false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("Player")


func _unhandled_input(event: InputEvent) -> void:
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		if event is InputEventScreenDrag:
			is_controller = false
			if get_window().size.x * 0.5 < event.position.x:
				_rotate_camera(event.relative, MOUSE_SENSITIVITY)
	else:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			is_controller = false
			_rotate_camera(event.relative, MOUSE_SENSITIVITY)
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		is_controller = true


func _input(event):
	if event.is_action_pressed("pause"):
		var new_mouse_mode: int = (
			Input.MOUSE_MODE_CAPTURED
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE
			else Input.MOUSE_MODE_VISIBLE
		)
		Input.set_mouse_mode(new_mouse_mode)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump"):
		_on_jump_pressed()

	var input_dir: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)

	if is_controller:
		var look_dir: Vector2 = Input.get_vector("look_left", "look_right", "look_up", "look_down")
		_rotate_camera(look_dir, CONTROLLER_SENSITIVITY)

	if Input.is_action_pressed("run") or is_player_running:
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED

	var direction: Vector3 = -(
		(head.transform.basis * Vector3(input_dir.x, 0, clampf(input_dir.y, -1, 1))).normalized()
	)

	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * AIR_ACCELERATION)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * AIR_ACCELERATION)

	bob_timer += velocity.length() * float(is_on_floor()) * delta
	camera.transform.origin = _bob_and_sway_player_head(bob_timer)

	var new_fov: float = BASE_FOV + FOV_CHANGE * clamp(velocity.length(), 0.5, RUN_SPEED * 2)
	camera.fov = lerp(camera.fov, new_fov, delta * 8.0)

	move_and_slide()


func _rotate_camera(motion: Vector2, sens: float) -> void:
	var sensitivity = sens if not inverted_mouse else -sens
	head.rotate_y(-motion.x * sensitivity)
	camera.rotate_x(-motion.y * sensitivity)
	camera.rotation.x = clampf(camera.rotation.x, -CAMERA_ANGLE_LIMIT, CAMERA_ANGLE_LIMIT)


func _on_jump_pressed() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY


func _bob_and_sway_player_head(timer: float) -> Vector3:
	var bob: float = sin(timer * BOB_FREQUENCY) * BOB_AMPLITUDE
	var sway: float = cos(timer * BOB_FREQUENCY * 0.5) * BOB_AMPLITUDE
	return Vector3(sway, bob, 0)
