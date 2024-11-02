extends Node
class_name Midi

var out: MidiOut

func _init() -> void:
	out = MidiOut.new()
	
func prepare_midi():
	out.open_port(2)

func play_note(message):
	out.send_message(message)
