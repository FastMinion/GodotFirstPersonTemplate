extends CharacterBody3D

const JUMP_VELOCITY: float = 4.5
const AIR_ACCELERATION: float = 3.0
const MOUSE_SENSITIVITY: float = 0.01
const WALK_SPEED: float = 5.0
const RUN_SPEED: float = 8.0
var speed: float = WALK_SPEED

const BOB_FREQUENCY: float = 2.0
const BOB_AMPLITUDE: float = 0.05
var bob_timer: float = 0.0

const BASE_FOV: float = 75.0
const FOV_CHANGE: float = 1.5

var gravity: float = 9.8

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/View


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


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

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("run"):
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED

	var input_dir: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)

	var direction: Vector3 = -(
		(head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
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


func _bob_and_sway_player_head(timer: float) -> Vector3:
	var bob: float = sin(timer * BOB_FREQUENCY) * BOB_AMPLITUDE
	var sway: float = cos(timer * BOB_FREQUENCY * 0.5) * BOB_AMPLITUDE
	return Vector3(sway, bob, 0)
