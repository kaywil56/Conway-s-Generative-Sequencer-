extends Node2D

enum TileType {
	DEAD,
	ALIVE,
	DEAD_TRIGGER,
	ALIVE_TRIGGER
}

const TileAtlasCoordinates = {
	TileType.DEAD: Vector2i(1, 1),
	TileType.ALIVE: Vector2i(1, 0),
	TileType.DEAD_TRIGGER: Vector2i(0, 1),
	TileType.ALIVE_TRIGGER: Vector2i(0, 0)
}
const GridWidth = 16
const GridHeight = 14

var scale_manager: ScaleManager
var note_manager: NoteManager
var trigger_manager: TriggerManager
var game_of_life: GameOfLife
var midi: Midi

@onready var tile_map_layer = $TileMapLayer
@onready var camera = $Camera2D
@onready var ui = $CanvasLayer/UserInterface
@onready var timer = $Timer

func _ready() -> void:
	game_of_life = GameOfLife.new(GridWidth, GridHeight)
	midi = Midi.new()
	trigger_manager = TriggerManager.new(GridWidth, GridHeight)
	scale_manager = ScaleManager.new()
	note_manager = NoteManager.new(self, tile_map_layer)

	var pattern_names = game_of_life.get_pattern_names()
	game_of_life.set_pattern(pattern_names[0])
	game_of_life.generate_pattern()
	var cells = game_of_life.get_cells()

	midi.prepare_midi()
	trigger_manager.add_triggers()
	trigger_manager.set_trigger_positions()
	
	draw_grid(cells)
	note_manager.add_notes(GridHeight)
	var notes = scale_manager.get_notes()
	var note_group_names = scale_manager.get_note_group_names()
	var note_groups = scale_manager.get_note_groups()
	var notes_in_group = scale_manager.get_notes_in_group(notes[0], note_group_names[0])
	note_manager.set_note_group(notes_in_group)
	note_manager.set_octave(4)
	note_manager.set_notes()
	
	ui.init_root_select_menu(notes)
	ui.init_note_group_menu(note_groups)
	ui.init_seed_select_menu(pattern_names)
	ui.set_octave(4)

	connect_signals()
	center_camera()

func center_camera():
	var size = Vector2i(GridWidth, GridHeight) * tile_map_layer.tile_set.tile_size
	camera.set_position(Vector2(size.x / 2, size.y / 2))
	
func connect_signals() -> void:
	ui.connect("note_group_selected", Callable(self, "handle_note_group_selected"))
	ui.connect("play", Callable(self, "handle_play"))
	ui.connect("bpm_selected", Callable(self, "handle_bpm_selected"))
	ui.connect("seed_selected", Callable(self, "handle_seed_selected"))
	ui.connect("octave_changed", Callable(self, "handle_octave_selected"))

func handle_octave_selected(octave: int) -> void:
	note_manager.set_octave(octave)
	note_manager.set_notes()

func handle_seed_selected(seed: String) -> void:
	game_of_life.set_pattern(seed)
	game_of_life.generate_pattern()
	var cells = game_of_life.get_cells()
	draw_grid(cells)

func handle_play(is_playing) -> void:
	if is_playing:
		timer.start()
	else:
		timer.stop()
		game_of_life.clear_cells()
		game_of_life.generate_pattern()
		var cells = game_of_life.get_cells()
		trigger_manager.set_trigger_positions()
		draw_grid(cells)

func handle_bpm_selected(bpm):
	ui.set_play_button(false)
	timer.wait_time = (60 / bpm) / 2

func handle_note_group_selected(root, note_groups) -> void:
	var notes_in_group = scale_manager.get_notes_in_group(root, note_groups)
	note_manager.set_note_group(notes_in_group)
	note_manager.set_notes()
	
func _on_timer_timeout() -> void:
	var cells = game_of_life.get_cells()
	draw_grid(cells)
	play_notes(cells)
	game_of_life.next_gen()
	trigger_manager.move_triggers()

func play_notes(cells):
	for cell in cells:
		var atlaas_coords = tile_map_layer.get_cell_atlas_coords(cell)
		if atlaas_coords == TileAtlasCoordinates[TileType.ALIVE_TRIGGER]:
			var note_node = note_manager.get_note_by_row(cell.y)
			var note_value = note_node.get_label()
			var note_number = scale_manager.note_to_midi_number(note_value)
			midi.play_note(note_number)

func draw_grid(cells) -> void:
	for position in cells:
		var trigger_at_position = trigger_manager.is_trigger_at_position(position)
		var alive_tile = TileAtlasCoordinates[TileType.ALIVE_TRIGGER] if trigger_at_position else TileAtlasCoordinates[TileType.ALIVE]
		var dead_tile = TileAtlasCoordinates[TileType.DEAD_TRIGGER] if trigger_at_position else TileAtlasCoordinates[TileType.DEAD]
		tile_map_layer.set_cell(position, 0, alive_tile if cells[position] else dead_tile)
