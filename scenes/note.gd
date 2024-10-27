extends Node2D

@onready var label = $Label

func set_label(text: String) -> void:
	label.text = text

func get_label() -> String:
	return label.text
