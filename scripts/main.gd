extends Node2D

enum TileType {
	DEAD,
	ALIVE
}

const TileAtlasCoordinates = {
	TileType.DEAD: Vector2i(0, 0),
	TileType.ALIVE: Vector2i(1, 0)
}

const GridWidth = 28
const GridHeight = 21

@onready var tile_map_layer = $TileMapLayer
@onready var camera = $Camera2D

var cells: Dictionary

func _ready() -> void:
	cells = {}
	random_seed()
	draw_grid()
	center_camera()

func center_camera():
	var size = Vector2i(GridWidth, GridHeight) * tile_map_layer.tile_set.tile_size
	camera.set_position(Vector2(size.x / 2, size.y / 2))
 
func random_seed() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var probability = 20
	for x in range(0, GridWidth):
		for y in range(0, GridHeight):
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
				var neighbor_row = (cell.x + i + GridWidth) % GridWidth
				var neighbor_col = (cell.y + j + GridHeight) % GridHeight
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
	
func draw_grid() -> void:
	for position in cells:
		tile_map_layer.set_cell(position, 0, TileAtlasCoordinates[TileType.ALIVE] if cells[position] else TileAtlasCoordinates[TileType.DEAD])

func _on_timer_timeout() -> void:
	draw_grid()
	next_gen()
