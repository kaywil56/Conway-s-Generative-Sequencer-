extends SeedPattern
class_name BlinkerPattern

func generate() -> Dictionary:
	var cells = _create_empty_grid()
	var pattern = [
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(2, 0)
	]
	_place_pattern(cells, pattern, grid_width/2, grid_height/2)
	return cells
