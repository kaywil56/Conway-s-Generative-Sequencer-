extends SeedPattern
class_name BlankPattern

func generate(grid_width, grid_height) -> Dictionary:
	var cells = _create_empty_grid(grid_width, grid_height)
	return cells
