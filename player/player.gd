extends CharacterBody3D

@export var JUMP_VELOCITY: float = 12.0
@export var FRICTION: float = 5.0
@export var ACCELERATION: float = 4.0
@export var MAX_SPEED: float = 15.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head: Node3D = $Head


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
		rotate_y(deg_to_rad(mouse_motion.relative.x * -0.1))
		head.rotate_x(deg_to_rad(mouse_motion.relative.y * -0.1))


func _input(event):
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
		velocity.y = JUMP_VELOCITY

	var input_dir: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)

	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var target_velocity: Vector3 = direction * MAX_SPEED
	var velocity_change: Vector3 = target_velocity - velocity
	velocity_change.y = 0

	var impulse: Vector3 = velocity_change * ACCELERATION * delta
	velocity += impulse

	velocity = velocity.lerp(Vector3.ZERO, FRICTION * delta)

	move_and_slide()
