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
const GridHeight = 18

var scale_manager: ScaleManager
var note_manager: NoteManager
var note_group_selection: Dictionary
var midi: Midi

@onready var tile_map_layer = $TileMapLayer
@onready var camera = $Camera2D
@onready var ui = $CanvasLayer/UserInterface

var cells: Dictionary

func _ready() -> void:
	midi = Midi.new()
	midi.prepare_midi()
	connect_signals()
	scale_manager = ScaleManager.new()
	note_manager = NoteManager.new(self, tile_map_layer)
	cells = {}
	random_seed()
	draw_grid()
	center_camera()
	var notes = scale_manager.get_notes()
	var note_groups = scale_manager.get_note_groups()
	note_group_selection = {
		"root": notes[0],
		"note_group": note_groups[0]
	}
	ui.init_root_select_menu(notes)
	ui.init_note_group_menu(note_groups)
	note_manager.add_notes()
	var notes_in_group = scale_manager.get_notes_in_group(note_group_selection)
	print(notes_in_group)
	note_manager.set_notes(notes_in_group)

func center_camera():
	var size = Vector2i(GridWidth, GridHeight) * tile_map_layer.tile_set.tile_size
	camera.set_position(Vector2(size.x / 2, size.y / 2))
	
func connect_signals() -> void:
	ui.connect("note_group_selected", Callable(self, "handle_note_group_selected"))

func handle_note_group_selected(root, note_groups) -> void:
	print_tree()
	note_group_selection["root"] = root
	note_group_selection["note_group"] = note_groups
	var notes_in_group = scale_manager.get_notes_in_group(note_group_selection)
	print(notes_in_group)
	note_manager.set_notes(notes_in_group)
	 
func random_seed() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var probability = 10
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

func play_notes():
	for cell in cells:
		if cells[cell]:
			var note_node = note_manager.get_note_by_position(cell)
			if note_node:
				var note_value = note_node.get_label()
				if note_value:
					var note_number = scale_manager.note_to_midi_number(note_value)
					midi.play_note(note_number)

func _on_timer_timeout() -> void:
	draw_grid()
	play_notes()
	next_gen()
