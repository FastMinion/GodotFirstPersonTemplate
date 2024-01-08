extends Control

signal btnJumPressed

func _ready()-> void:
	if OS.get_name() != "Android":
		queue_free()

func _on_texture_button_pressed():
	emit_signal("btnJumpPressed")
