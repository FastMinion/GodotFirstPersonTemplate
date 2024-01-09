extends Control

@export var THRESHOLD: float = 0.1

var MAX_POS: Vector2 = Vector2.ZERO
var DEFAULT_POSITION: Vector2 = Vector2.ZERO

var axis_vector: Vector2 = Vector2.ZERO:
	get:
		return axis_vector

@onready var outer: TextureRect = $Outer
@onready var inside: TextureRect = $Outer/Inner

func _ready() -> void:
	if OS.get_name() != "Android":
		queue_free()
	MAX_POS = Vector2(outer.size.x - inside.size.x,outer.size.y - inside.size.y)
	DEFAULT_POSITION = Vector2(MAX_POS.x/2, MAX_POS.y/2)
	inside.position = DEFAULT_POSITION

func in_threshold(value: float) -> float:
	if abs(value) < THRESHOLD:
		return 0.0
	return value
	
func _physics_process(_delta):
	axis_vector = Vector2(
		in_threshold((inside.position.x - DEFAULT_POSITION.x)/DEFAULT_POSITION.x),
		in_threshold((inside.position.y - DEFAULT_POSITION.y)/DEFAULT_POSITION.y)
	)

func _on_inner_gui_input(event) -> void:
	if event is InputEventScreenTouch:
		if not event.is_pressed():
			inside.position = DEFAULT_POSITION

	if event is InputEventScreenDrag:
		inside.position += event.relative
		inside.position.x = clampf(inside.position.x, 0, MAX_POS.x)
		inside.position.y = clampf(inside.position.y, -MAX_POS.y, MAX_POS.y)
	
