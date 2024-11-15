extends Node
class_name ScaleManager

const NoteGroups = {
  "scales": {
	"Minor (Aeolian)": [0, 2, 3, 5, 7, 8, 10],
	"Major (Ionian)": [0, 2, 4, 5, 7, 9, 11],
	"Minor Harmonic": [0, 2, 3, 5, 7, 8, 11],
	"Minor Melodic": [0, 2, 3, 5, 7, 9, 11],
	"Dorian": [0, 2, 3, 5, 7, 9, 10],
	"Phrygian": [0, 1, 3, 5, 7, 8, 10],
	"Lydian": [0, 2, 4, 6, 7, 9, 11],
	"Mixolydian": [0, 2, 4, 5, 7, 9, 10],
	"Locrian": [0, 1, 3, 5, 6, 8, 10],
	"Minor Pentatonic": [0, 3, 5, 7, 10],
	"Major Pentatonic": [0, 2, 4, 7, 9],
	"Blues": [0, 3, 5, 6, 7, 10],
	"Whole Tone": [0, 2, 4, 6, 8, 10],
	"Diminished (Half-Whole)": [0, 1, 3, 4, 6, 7, 9, 10]
  },
  "chords": {
	"Minor": [0, 3, 7],
	"Minor 7th": [0, 3, 7, 10],
	"Minor 9th": [0, 3, 7, 10, 14],
	"Major": [0, 4, 7],
	"Major 7th": [0, 4, 7, 11],
	"Fifth": [0, 7],
	"Fifth 9th": [0, 7, 14],
	"Diminished": [0, 3, 6],
	"Diminished 7th": [0, 3, 6, 9],
	"Augmented": [0, 4, 8],
	"Major 9th": [0, 4, 7, 11, 14],
	"Dominant 7th": [0, 4, 7, 10],
	"Dominant 9th": [0, 4, 7, 10, 14]
  }
};

const Notes = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']

func get_notes_in_group(root: String, note_group: String) -> Array:
	var root_position = Notes.find(root, 0)
	var notes_in_group = []
	var category = get_category(note_group)
	for i in NoteGroups[category][note_group]:
		notes_in_group.append(Notes[(root_position + i) % Notes.size()])
	return notes_in_group

func note_to_midi_number(note_name: String) -> int:
	var note = note_name.left(len(note_name) - 1).to_upper()
	var octave = int(note_name.right(1))
	var note_index = Notes.find(note)
	
	return note_index if note_index == -1 else 12 * octave + note_index
	
func get_notes() -> Array:
	return Notes
	
func get_note_group_names() -> Array:
	var chords = NoteGroups["chords"].keys()
	var scales = NoteGroups["scales"].keys()
	scales += chords
	return scales

func get_note_groups() -> Dictionary:
	return NoteGroups
	
func get_category(group) -> String:
	for i in NoteGroups:
		if NoteGroups[i].has(group):
			return i
	return ""
