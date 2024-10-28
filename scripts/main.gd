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
var game_of_life: GameOfLife
var midi: Midi

@onready var tile_map_layer = $TileMapLayer
@onready var camera = $Camera2D
@onready var ui = $CanvasLayer/UserInterface
@onready var timer = $Timer

func _ready() -> void:
	midi = Midi.new()
	game_of_life = GameOfLife.new(GridWidth, GridHeight)
	midi.prepare_midi()
	connect_signals()
	scale_manager = ScaleManager.new()
	note_manager = NoteManager.new(self, tile_map_layer)
	game_of_life.random_seed()
	var cells = game_of_life.get_cells()
	draw_grid(cells)
	center_camera()
	var notes = scale_manager.get_notes()
	var note_group_names = scale_manager.get_note_group_names()
	var note_groups = scale_manager.get_note_groups()
	ui.init_root_select_menu(notes)
	ui.init_note_group_menu(note_groups)
	note_manager.add_notes()
	var notes_in_group = scale_manager.get_notes_in_group(notes[0], note_group_names[0])
	note_manager.set_notes(notes_in_group)

func center_camera():
	var size = Vector2i(GridWidth, GridHeight) * tile_map_layer.tile_set.tile_size
	camera.set_position(Vector2(size.x / 2, size.y / 2))
	
func connect_signals() -> void:
	ui.connect("note_group_selected", Callable(self, "handle_note_group_selected"))
	ui.connect("play", Callable(self, "handle_play"))

func handle_play(is_playing) -> void:
	if is_playing:
		timer.start()
	else:
		timer.stop()
		game_of_life.clear_cells()
		game_of_life.random_seed()
		var cells = game_of_life.get_cells()
		draw_grid(cells)

func handle_note_group_selected(root, note_groups) -> void:
	var notes_in_group = scale_manager.get_notes_in_group(root, note_groups)
	note_manager.set_notes(notes_in_group)
	
func _on_timer_timeout() -> void:
	var cells = game_of_life.get_cells()
	draw_grid(cells)
	play_notes(cells)
	game_of_life.next_gen()

func play_notes(cells):
	for cell in cells:
		if cells[cell]:
			var note_node = note_manager.get_note_by_position(cell)
			if note_node:
				var note_value = note_node.get_label()
				if note_value:
					var note_number = scale_manager.note_to_midi_number(note_value)
					midi.play_note(note_number)

func draw_grid(cells) -> void:
	for position in cells:
		tile_map_layer.set_cell(position, 0, TileAtlasCoordinates[TileType.ALIVE] if cells[position] else TileAtlasCoordinates[TileType.DEAD])
