extends Node2D

@onready var label = $Control/Label
@onready var slider = $Control/HSlider
@onready var control = $Control

func set_label(text: String) -> void:
	label.text = text

func get_label() -> String:
	return label.text

func set_slider(new_value: int) -> void:
	slider.value = new_value
	
func get_slider() -> int:
	return slider.value

func get_width():
	return control.get_global_rect().size.x
