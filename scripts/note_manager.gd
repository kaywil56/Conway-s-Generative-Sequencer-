extends Node
class_name NoteManager

var parent: Node2D
var tile_map_layer: TileMapLayer
var note_scene = preload("res://scenes/note.tscn")
var note_instances: Dictionary
var skip_every: int

func _init(new_parent, new_tile_map_layer) -> void:
	parent = new_parent
	tile_map_layer = new_tile_map_layer
	note_instances = {}
	skip_every = 20

func add_notes() -> void:
	var used_cells = tile_map_layer.get_used_cells()
	for cell in used_cells:
		_add_note(cell)

func _add_note(position: Vector2i) -> void:
	var global_cell_position = tile_map_layer.map_to_local(position)
	var note_instance = note_scene.instantiate()
	note_instance.global_position = global_cell_position
	parent.add_child(note_instance)
	note_instances[position] = note_instance
	
func set_notes(note_group: Array) -> void:
	var skip_count = 0
	var note_instances_values = note_instances.values()
	for i in range(0, note_instances_values.size()):
		if i % skip_every == 0:
			note_instances_values[i].set_label(str(note_group[skip_count % note_group.size()], "5"))
			skip_count += 1

func get_note_by_position(position: Vector2i) -> Node2D:
	if note_instances.has(position):
		return note_instances[position]
	else:
		return null
