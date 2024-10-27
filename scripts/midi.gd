extends Node
class_name Midi

var out: MidiOut

func _init() -> void:
	out = MidiOut.new()
	
func prepare_midi():
	out.open_port(2)

func play_note(note):
	var message = PackedByteArray()
	message.append(0x90) # Note on
	message.append(note) # Note number
	message.append(127) # Velocity
	out.send_message(message)
