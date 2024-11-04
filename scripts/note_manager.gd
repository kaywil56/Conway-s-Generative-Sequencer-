extends Node
class_name NoteManager

var parent: Node2D
var tile_map_layer: TileMapLayer
var note_scene = preload("res://scenes/note.tscn")
var note_instances: Dictionary
var octave: int
var note_group: Array
var grid_height_multi: int

func _init(new_parent, new_tile_map_layer, new_grid_height_multi) -> void:
	parent = new_parent
	tile_map_layer = new_tile_map_layer
	note_instances = {}
	grid_height_multi = new_grid_height_multi

func set_grid_height_multi(height_multi: int) -> void:
	grid_height_multi = height_multi 
	
func add_notes() -> void:
	var grid_height = grid_height_multi * note_group.size()
	for i in range(0, grid_height):
		var cell = Vector2i(0, i) + Vector2i.LEFT
		_add_note(cell)

func set_note_group(new_note_group: Array) -> void:
	note_group = new_note_group

func set_octave(new_octave: int) -> void:
	octave = new_octave

func get_note_group() -> Array:
	return note_group

func get_octave() -> int:
	return octave

func _add_note(position: Vector2i) -> void:
	var global_cell_position = tile_map_layer.map_to_local(position)
	var note_instance = note_scene.instantiate()
	note_instance.global_position = global_cell_position
	parent.add_child(note_instance)
	note_instances[position.y] = note_instance
	
func set_notes() -> void:
	var current_octave = octave
	for i in range(0, note_instances.size()):
		if i % note_group.size() == 0:
			current_octave += 1
		note_instances[i].label.text = str(note_group[i % note_group.size()], current_octave - 1)

func get_note_by_row(y: int) -> Node2D:
	if note_instances.has(y):
		return note_instances[y]
	else:
		return null

func set_sliders_max() -> void:
	for note in note_instances:
		note_instances[note].set_slider(10)

func set_sliders_random() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for note in note_instances:
		var random = rng.randi_range(0, 10)
		note_instances[note].set_slider(random)

func clear_notes() -> void:
	for note in note_instances:
		note_instances[note].queue_free()
	note_instances.clear()
