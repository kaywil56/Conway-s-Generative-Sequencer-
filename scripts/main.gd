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
const Bar = 4

var scale_manager: ScaleManager
var note_manager: NoteManager
var trigger_manager: TriggerManager
var game_of_life: GameOfLife
var midi: Midi
var midi_buffer: Array
var bpm: int
var offset: int

@onready var tile_map_layer = $TileMapLayer
@onready var camera = $Camera2D
@onready var ui = $CanvasLayer/UserInterface
@onready var timer = $Timer
@onready var visibility_notifier = $VisibleOnScreenNotifier2D

func _ready() -> void:
	bpm = 120
	offset = 1
	game_of_life = GameOfLife.new(GridWidth, GridHeight)

	var pattern_names = game_of_life.get_pattern_names()
	game_of_life.set_pattern(pattern_names[0])
	game_of_life.generate_pattern()
	var cells = game_of_life.get_cells()
	draw_grid(cells)
	
	midi = Midi.new()
	trigger_manager = TriggerManager.new(tile_map_layer, self, GridHeight, GridWidth)
	scale_manager = ScaleManager.new()
	note_manager = NoteManager.new(self, tile_map_layer, 2)

	midi.prepare_midi()

	trigger_manager.add_triggers()
	trigger_manager.set_trigger_positions()
	var notes = scale_manager.get_notes()
	var note_group_names = scale_manager.get_note_group_names()
	var note_groups = scale_manager.get_note_groups()
	var notes_in_group = scale_manager.get_notes_in_group(notes[0], note_group_names[0])
	note_manager.set_note_group(notes_in_group)
	note_manager.set_octave(4)
	note_manager.add_notes()
	note_manager.set_notes()
	note_manager.set_sliders_max()
	
	ui.init_root_select_menu(notes)
	ui.init_note_group_menu(note_groups)
	ui.init_seed_select_menu(pattern_names)
	ui.set_octave(4)

	connect_signals()
	center_camera()

func center_camera():
	var used_rect = tile_map_layer.get_used_rect()
	var used_rect_size = used_rect.size
	var tile_size = tile_map_layer.tile_set.tile_size
	var size = used_rect_size * tile_size
	camera.set_position(Vector2(size.x / 2, size.y / 2))
	var viewport_size = get_viewport_rect().size
	var padding = 1.2
	var zoom_x = (viewport_size.x / size.x) / padding
	var zoom_y = (viewport_size.y / size.y) / padding
	var zoom = min(zoom_x, zoom_y)
	zoom = clamp(zoom, 0.1, 1.0)
	camera.zoom = Vector2(zoom, zoom)

func connect_signals() -> void:
	ui.connect("note_group_selected", Callable(self, "handle_note_group_selected"))
	ui.connect("play", Callable(self, "handle_play"))
	ui.connect("bpm_selected", Callable(self, "handle_bpm_selected"))
	ui.connect("seed_selected", Callable(self, "handle_seed_selected"))
	ui.connect("octave_changed", Callable(self, "handle_octave_selected"))
	ui.connect("randomize_probability", Callable(self, "handle_randomize_probability"))
	ui.connect("grid_width_selected", Callable(self, "handle_grid_width_selected"))
	ui.connect("grid_height_selected", Callable(self, "handle_grid_height_selected"))
	ui.connect("offset_selected", Callable(self, "handle_offset_selected"))

func handle_offset_selected(value):
	if value == "None":
		offset = 1
		return
	var new_offset = value.replace("th", "")
	new_offset = new_offset.replace("/", "")
	new_offset = new_offset.replace("1", "")
	offset = int(new_offset)

func handle_grid_height_selected(height: String) -> void:
	var height_value = height.left(1)
	height_value = int(height_value) * note_manager.get_note_group().size()
	game_of_life.set_grid_height(height_value)
	game_of_life.generate_pattern()
	var cells = game_of_life.get_cells()
	draw_grid(cells)
	center_camera()
	trigger_manager.set_grid_height(height_value)
	trigger_manager.clear_triggers()
	trigger_manager.add_triggers()
	trigger_manager.set_trigger_positions()
	
	note_manager.set_grid_height_multi(int(height.left(1)))
	note_manager.clear_notes()
	note_manager.add_notes()
	note_manager.set_notes()
	note_manager.set_sliders_max()
	
func handle_grid_width_selected(width: String) -> void:
	var width_value = width.replace("BAR(S)","")
	width_value = Bar * int(width_value)
	print(width_value)
	game_of_life.set_grid_width(width_value)
	game_of_life.generate_pattern()
	var cells = game_of_life.get_cells()
	draw_grid(cells)
	center_camera()
	trigger_manager.set_grid_width(width_value)
	trigger_manager.clear_triggers()
	trigger_manager.add_triggers()
	trigger_manager.set_trigger_positions()

func handle_octave_selected(octave: int) -> void:
	note_manager.set_octave(octave)
	note_manager.set_notes()
	
func handle_randomize_probability() -> void:
	note_manager.set_sliders_random()

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
		play_note_off()
		game_of_life.clear_cells()
		game_of_life.generate_pattern()
		var cells = game_of_life.get_cells()
		trigger_manager.set_trigger_positions()
		draw_grid(cells)

func handle_bpm_selected(new_bpm):
	bpm = new_bpm
	timer.wait_time = 60 / bpm

func handle_note_group_selected(root, note_groups) -> void:
	var notes_in_group = scale_manager.get_notes_in_group(root, note_groups)
	note_manager.set_note_group(notes_in_group)
	var grid_height_value = ui.get_grid_height()
	handle_grid_height_selected(grid_height_value)
	
func _on_timer_timeout() -> void:
	var base = (60.0 / bpm)
	if offset == 1:
		timer.wait_time = base
	else:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var max_offset: float = (60.0 / bpm) * (4.0 / offset)
		var base_with_offset = base + rng.randf_range(-max_offset, max_offset)
		print(base_with_offset)
		timer.wait_time = base_with_offset
	var cells = game_of_life.get_cells()
	draw_grid(cells)
	trigger_manager.move_triggers()
	play_notes(cells)
	game_of_life.next_gen()

func play_notes(cells):
	play_note_off()
	for cell in cells:
		var trigger_at_position = trigger_manager.is_trigger_at_position(cell)
		if trigger_at_position and cells[cell]:
			var note_node = note_manager.get_note_by_row(cell.y)
			var rng = RandomNumberGenerator.new()
			rng.randomize()
			var random = rng.randi_range(0, 10)
			var slider_value = note_node.get_slider()
			if slider_value == 0:
				return
			if random <= slider_value:
				var note_value = note_node.get_label()
				var note_number = scale_manager.note_to_midi_number(note_value)
				var message = PackedByteArray()
				message.append(0x90)
				message.append(note_number)
				message.append(100)
				midi.play_note(message)
				trigger_at_position.animate()
				midi_buffer.append(note_number)

func play_note_off() -> void:
	for note in midi_buffer:
		var message = PackedByteArray()
		message.append(0x80)
		message.append(note)
		message.append(0)
		midi.play_note(message)
	midi_buffer.clear()

func draw_grid(cells) -> void:
	tile_map_layer.clear()
	for position in cells:
		tile_map_layer.set_cell(position, 0, TileAtlasCoordinates[TileType.ALIVE] if cells[position] else TileAtlasCoordinates[TileType.DEAD])

func get_snapped_position() -> Vector2i:
	var mouse_position = get_global_mouse_position()
	return tile_map_layer.local_to_map(mouse_position)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var snapped_position = get_snapped_position()
		var within_grid = is_within_grid(snapped_position)
		if not within_grid:
			return
		game_of_life.add_cell(snapped_position)
		var cells = game_of_life.get_cells()
		draw_grid(cells)
	if event.is_action_pressed("right_click"):
		var snapped_position = get_snapped_position()
		var within_grid = is_within_grid(snapped_position)
		if not within_grid:
			return
		game_of_life.remove_cell(snapped_position)
		var cells = game_of_life.get_cells()
		draw_grid(cells)

func is_within_grid(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < GridWidth and pos.y >= 0 and pos.y < GridHeight
