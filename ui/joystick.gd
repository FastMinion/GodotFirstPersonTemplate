extends Control

signal onJoyMove(axis_h,axis_v)

@export var THRESHOLD: float = 0.1

var MAX_POS: Vector2 = Vector2.ZERO
var DEFAULT_POSITION: Vector2 = Vector2.ZERO

var axis_h: float = 0.0
var axis_v: float = 0.0

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

func _physics_process(_delta) -> void:
	emit_signal("onJoyMove",axis_h,axis_v)

func _on_inner_gui_input(event) -> void:
	if event is InputEventScreenTouch:
		if not event.is_pressed():
			inside.position = DEFAULT_POSITION
			
			axis_h = in_threshold((inside.position.x - DEFAULT_POSITION.x)/DEFAULT_POSITION.x)
			axis_v = in_threshold((inside.position.y - DEFAULT_POSITION.y)/DEFAULT_POSITION.y)

	if event is InputEventScreenDrag:
		inside.position += event.relative
		inside.position.x = clampf(inside.position.x, 0, MAX_POS.x)
		inside.position.y = clampf(inside.position.y, 0, MAX_POS.y)
		
		axis_h = in_threshold((inside.position.x - DEFAULT_POSITION.x)/DEFAULT_POSITION.x)
		axis_v = in_threshold((inside.position.y - DEFAULT_POSITION.y)/DEFAULT_POSITION.y)
