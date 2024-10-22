extends Node2D

const GRID_WIDTH = 30
const GRID_HEIGHT = 20

@onready var tile_map_layer = $TileMapLayer
@onready var camera = $Camera2D

func _ready() -> void:
	draw_grid()
	center_camera()

func center_camera():
	var size = Vector2i(GRID_WIDTH, GRID_HEIGHT) * tile_map_layer.tile_set.tile_size
	camera.set_position(Vector2(size.x / 2, size.y / 2))

func draw_grid() -> void:
	# Draw base grid
	for x in range(0, GRID_WIDTH):
		for y in range(0, GRID_HEIGHT):
			tile_map_layer.set_cell(Vector2i(x, y), 1, Vector2i(0, 0), 0)
	
