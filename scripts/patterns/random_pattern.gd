extends SeedPattern
class_name RandomPattern

func generate(grid_width: int, grid_height: int) -> Dictionary:
	var cells = {}
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var probability = 20
	
	for x in range(0, grid_width):
		for y in range(0, grid_height):
			var random = rng.randi_range(0, 100)
			cells[Vector2i(x, y)] = 1 if random <= probability else 0
	
	return cells
