extends Node
class_name GameOfLife

var cells: Dictionary
var grid_width: int
var grid_height: int
var patterns: Dictionary
var selected_pattern: SeedPattern

func _init(new_grid_width, new_grid_height) -> void:
	cells = {}
	patterns = {}
	grid_width = new_grid_width
	grid_height = new_grid_height
	initialize_patterns()

func initialize_patterns() -> void:
	patterns = {
		"random": RandomPattern.new(grid_width, grid_height),
		"blinker": BlinkerPattern.new(grid_width, grid_height)
	}
	
func set_pattern(pattern_name: String) -> void:
	if patterns.has(pattern_name):
		selected_pattern = patterns[pattern_name]
		
func generate_pattern() -> void:
	if selected_pattern:
		cells = selected_pattern.generate()

func get_pattern_names() -> Array:
	return patterns.keys()

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
