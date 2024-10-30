class_name TriggerManager
extends Node2D

var triggers: Array
var grid_width: int
var grid_height: int

func _init(new_grid_width, new_grid_height) -> void:
	triggers = []
	grid_width = new_grid_width
	grid_height = new_grid_height

func add_triggers() -> void:
	for i in range(0, grid_height):
		triggers.append(Vector2i.ZERO)

func move_triggers() -> void:
	for i in range(triggers.size()):
		triggers[i] += Vector2i.RIGHT
	var reached_end = _reached_end()
	if reached_end:
		set_trigger_positions()

func set_trigger_positions() -> void:
	for i in range(0, grid_height):
		triggers[i] = Vector2i(0, i)

func get_triggers() -> Array:
	return triggers

func is_trigger_at_position(position: Vector2i) -> bool:
	return triggers.has(position)

func _reached_end():
	return triggers[0].x == grid_width
