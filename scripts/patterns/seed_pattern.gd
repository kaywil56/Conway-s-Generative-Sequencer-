class_name SeedPattern
extends RefCounted

var grid_width: int
var grid_height: int

func _init(width: int, height: int) -> void:
	grid_width = width
	grid_height = height

func _place_pattern(cells: Dictionary, pattern: Array, center_x: int, center_y: int) -> void:
	for pos in pattern:
		cells[Vector2i(center_x + pos.x, center_y + pos.y)] = 1

func _create_empty_grid() -> Dictionary:
	var cells = {}
	for x in range(0, grid_width):
		for y in range(0, grid_height):
			cells[Vector2i(x, y)] = 0
	return cells

func generate() -> Dictionary:
	return {}
