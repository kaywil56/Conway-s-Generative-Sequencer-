extends Node
class_name NoteManager

var parent: Node2D
var tile_map_layer: TileMapLayer
var note_scene = preload("res://scenes/note.tscn")
var note_instances: Dictionary
var octave: int
var note_group: Array

func _init(new_parent, new_tile_map_layer) -> void:
	parent = new_parent
	tile_map_layer = new_tile_map_layer
	note_instances = {}

func add_notes(grid_height) -> void:
	var used_cells = tile_map_layer.get_used_cells()
	for i in range(0, grid_height):
		var cell = used_cells[i] + Vector2i.LEFT
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
	for i in range(0, note_instances.size()):
		if i % note_group.size() == 0:
			octave += 1
		note_instances[i].label.text = str(note_group[i % note_group.size()], octave - 1)

func get_note_by_row(y: int) -> Node2D:
	if note_instances.has(y):
		return note_instances[y]
	else:
		return null
