extends Node2D

enum TileType {
	BASE,
	DEAD,
	ALIVE
}

const TileAtlasCoordinates = {
	TileType.BASE: Vector2i(0, 0),
	TileType.DEAD: Vector2i(0, 1),
	TileType.ALIVE: Vector2i(1, 0)
}

const GridWidth = 30
const GridHeight = 20

@onready var tile_map_layer = $TileMapLayer
@onready var camera = $Camera2D

var cells = []

func _ready() -> void:
	random_seed()
	draw_grid()
	center_camera()

func center_camera():
	var size = Vector2i(GridWidth, GridHeight) * tile_map_layer.tile_set.tile_size
	camera.set_position(Vector2(size.x / 2, size.y / 2))
 
func random_seed() -> void:
	var rng = RandomNumberGenerator.new()
	var probability = 20
	for x in range(0, GridWidth):
		for y in range(0, GridHeight):
			var random = rng.randi_range(0, 100)
			if random <= probability: 
				cells.append({
					"position": Vector2i(x, y),
					"is_alive": true
				})
	
func draw_grid() -> void:
	# Draw base grid
	for x in range(0, GridWidth):
		for y in range(0, GridHeight):
			tile_map_layer.set_cell(Vector2i(x, y), 0, TileAtlasCoordinates[TileType.BASE])
	
	for cell in cells:
		tile_map_layer.set_cell(cell["position"], 0, TileAtlasCoordinates[TileType.ALIVE] if cell["is_alive"] else TileAtlasCoordinates[TileType.DEAD])
