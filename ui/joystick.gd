extends Control

@export var THRESHOLD: float = 0.1
@export var joystick_left_action: String
@export var joystick_right_action: String
@export var joystick_up_action: String
@export var joystick_down_action: String

const RUN_ACTIVATION_THRESHOLD: float = -1.5

var MAX_POS: Vector2 = Vector2.ZERO
var BASE_POSITION: Vector2 = Vector2.ZERO

var player: CharacterBody3D

@onready var outer: TextureRect = $Outer
@onready var inside: TextureRect = $Outer/Inner

var joystick_left_event: InputEventAction = InputEventAction.new()
var joystick_right_event: InputEventAction = InputEventAction.new()
var joystick_up_event: InputEventAction = InputEventAction.new()
var joystick_down_event: InputEventAction = InputEventAction.new()


func _ready() -> void:
	if OS.get_name() != "Android" and OS.get_name() != "iOS":
		queue_free()
	MAX_POS = Vector2(outer.size.x - inside.size.x, outer.size.y - inside.size.y)
	BASE_POSITION = Vector2(MAX_POS.x * 0.5, MAX_POS.y * 0.5)
	inside.position = BASE_POSITION
	player = get_tree().get_first_node_in_group("Player")

	joystick_left_event.action = joystick_left_action
	joystick_right_event.action = joystick_right_action
	joystick_up_event.action = joystick_up_action
	joystick_down_event.action = joystick_down_action


func _in_threshold(value: float) -> float:
	if abs(value) < THRESHOLD:
		return 0.0
	return value


func _physics_process(delta):
	var axis_vector: Vector2 = Vector2(
		_in_threshold((inside.position.x - BASE_POSITION.x) / BASE_POSITION.x),
		_in_threshold((inside.position.y - BASE_POSITION.y) / BASE_POSITION.y)
	)
	_axis_to_input_event_x(axis_vector)
	_axis_to_input_event_y(axis_vector)
	Input.flush_buffered_events()


func _axis_to_input_event_x(axis_vector: Vector2) -> void:
	joystick_left_event.pressed = axis_vector.x < 0
	joystick_right_event.pressed = axis_vector.x > 0
	Input.parse_input_event(joystick_left_event)
	Input.parse_input_event(joystick_right_event)


func _axis_to_input_event_y(axis_vector: Vector2):
	player.is_player_running = axis_vector.y < RUN_ACTIVATION_THRESHOLD
	joystick_up_event.pressed = axis_vector.y < 0
	joystick_down_event.pressed = axis_vector.y > 0
	Input.parse_input_event(joystick_up_event)
	Input.parse_input_event(joystick_down_event)


func _input_event_timeout(sec: float):
	return get_tree().create_timer(sec).timeout


func _on_inner_gui_input(event) -> void:
	if event is InputEventScreenTouch:
		if not event.is_pressed():
			inside.position = BASE_POSITION

	if event is InputEventScreenDrag:
		inside.position = Vector2(
			clampf(inside.position.x + event.relative.x, 0, MAX_POS.x),
			clampf(inside.position.y + event.relative.y, -MAX_POS.y, MAX_POS.y)
		)
