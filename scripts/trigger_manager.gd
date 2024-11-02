class_name TriggerManager
extends Node2D

var triggers: Array
var trigger_scene = preload("res://scenes/trigger.tscn")
var tile_map_layer: TileMapLayer
var parent: Node2D

func _init(new_tile_map_layer, new_parent) -> void:
	triggers = []
	tile_map_layer = new_tile_map_layer
	parent = new_parent
	
func add_triggers() -> void:
	var used_rect = tile_map_layer.get_used_rect().size
	for i in range(0, used_rect.y):
		var trigger_instance = trigger_scene.instantiate()
		trigger_instance.global_position = Vector2i.ZERO
		parent.add_child(trigger_instance)
		triggers.append(trigger_instance)

func move_triggers() -> void:
	for i in range(triggers.size()):
		triggers[i].global_position = tile_map_layer.map_to_local(tile_map_layer.local_to_map(triggers[i].global_position) + Vector2i.RIGHT)
	var reached_end = _reached_end()
	if reached_end:
		set_trigger_positions()

func set_trigger_positions() -> void:
	var used_rect = tile_map_layer.get_used_rect().size
	for i in range(0, used_rect.y):
		triggers[i].global_position = tile_map_layer.map_to_local(Vector2i(0, i))

func get_triggers() -> Array:
	return triggers
	
func is_trigger_at_position(position: Vector2i) -> Node2D:
	for trigger in triggers:
		if tile_map_layer.local_to_map(trigger.global_position) == position:
			return trigger
	return null

func _reached_end():
	var used_rect = tile_map_layer.get_used_rect().size
	return tile_map_layer.local_to_map(triggers[0].global_position).x == used_rect.x
