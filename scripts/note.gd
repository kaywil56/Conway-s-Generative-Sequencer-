extends Node2D

@onready var label = $Control/Label
@onready var slider = $Control/HSlider

func set_label(text: String) -> void:
	label.text = text

func get_label() -> String:
	return label.text

func set_slider(new_value: int) -> void:
	slider.value = new_value
	
func get_slider() -> int:
	return slider.value
