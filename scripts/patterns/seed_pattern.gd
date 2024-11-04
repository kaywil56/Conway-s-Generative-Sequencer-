class_name SeedPattern
extends RefCounted

func _place_pattern(cells: Dictionary, pattern: Array, center_x: int, center_y: int) -> void:
	for pos in pattern:
		cells[Vector2i(center_x + pos.x, center_y + pos.y)] = 1

func _create_empty_grid(grid_width: int, grid_height: int) -> Dictionary:
	var cells = {}
	for x in range(0, grid_width):
		for y in range(0, grid_height):
			cells[Vector2i(x, y)] = 0
	return cells

func generate(grid_width: int, grid_height: int) -> Dictionary:
	return {}
