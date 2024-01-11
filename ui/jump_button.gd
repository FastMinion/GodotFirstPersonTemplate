extends Control

@export var button_normal_texture: Texture2D
@export var on_button_press_action: String

@onready var button = $TextureButton

var button_event: InputEventAction = InputEventAction.new()


func _ready() -> void:
	if OS.get_name() != "Android" and OS.get_name() != "iOS":
		queue_free()
	button.texture_normal = button_normal_texture
	button_event.action = on_button_press_action


func _on_texture_button_pressed():
	button_event.pressed = true
	Input.parse_input_event(button_event)
	await get_tree().create_timer(0.1).timeout
	button_event.pressed = false
	Input.parse_input_event(button_event)
