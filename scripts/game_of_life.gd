extends Node
class_name GameOfLife

var cells: Dictionary
var grid_width: int
var grid_height: int

func _init(new_grid_width, new_grid_height) -> void:
	cells = {}
	grid_width = new_grid_width
	grid_height = new_grid_height

func random_seed() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var probability = 10
	for x in range(0, grid_width):
		for y in range(0, grid_height):
			var random = rng.randi_range(0, 100)
			if random <= probability: 
				cells[Vector2i(x, y)] = 1
			else:
				cells[Vector2i(x, y)] = 0

func get_neighbors(cell: Vector2i) -> int:
	var total = 0 
	for i in range(-1, 2):
		for j in range(-1, 2):
			# exclude self
			if i != 0 or j != 0: 
				var neighbor_row = (cell.x + i + grid_width) % grid_width
				var neighbor_col = (cell.y + j + grid_height) % grid_height
				total += cells[Vector2i(neighbor_row, neighbor_col )]
	return total

func next_gen() -> void:
	var new_cells = cells.duplicate()
	for position in cells:
		var live_neighbors = get_neighbors(position)
		if cells[position] == 1:
			if live_neighbors < 2 or live_neighbors > 3:
				new_cells[position] = 0
			else:
				new_cells[position] = 1
		else:
			if live_neighbors == 3:
				new_cells[position] = 1
	cells = new_cells

func get_cells() -> Dictionary:
	return cells

func clear_cells() -> void:
	cells.clear()
