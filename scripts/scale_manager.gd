extends Node
class_name ScaleManager

const NoteGroups = {
	"Minor (Aeolian)": [0, 2, 3, 5, 7, 8, 10],
	"Major": [0, 2, 4, 5, 7, 9, 11],
	"Minor 7th": [0, 3, 7, 10],
	"Minor": [0, 3, 7]
}
const Notes = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']

func get_notes_in_group(note_group_selection: Dictionary) -> Array:
	var root_position = Notes.find(note_group_selection["root"], 0)
	var notes_in_group = []
	for i in NoteGroups[note_group_selection["note_group"]]:
		notes_in_group.append(Notes[(root_position + i) % Notes.size()])
	return notes_in_group

func note_to_midi_number(note_name: String) -> int:
	var note = note_name.left(len(note_name) - 1).to_upper()
	var octave = int(note_name.right(1))
	var note_index = Notes.find(note)
	
	return note_index if note_index == -1 else 12 * octave + note_index
	
func get_notes() -> Array:
	return Notes
	
func get_note_groups() -> Array:
	return NoteGroups.keys()
