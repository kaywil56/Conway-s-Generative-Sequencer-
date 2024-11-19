extends Node
class_name Midi

var out: MidiOut

func _init() -> void:
	out = MidiOut.new()
	
func prepare_midi():
	out.open_port(2)
	
func get_ports() -> PackedStringArray:
	var port_names = out.get_port_names()
	return port_names

func open_port(port: int) -> void:
	out.open_port(port)

func play_note(message):
	out.send_message(message)
