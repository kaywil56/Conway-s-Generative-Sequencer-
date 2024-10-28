extends Control
signal note_group_selected(root, note_group)
signal play(toggled)
signal bpm_selected(bpm)

@onready var root_note_option_button = $TopBarHBoxContainer/NoteGroupSelectionHBoxContainer/RootNoteOptionButton
@onready var note_group_option_button = $TopBarHBoxContainer/NoteGroupSelectionHBoxContainer/NoteGroupOptionButton
@onready var play_button = $TopBarHBoxContainer/PlayButton

func _ready() -> void:
	connect_signals()

func init_note_group_menu(note_groups: Dictionary) -> void:
	var popup = note_group_option_button.get_popup()
	for i in note_groups:
		popup.add_separator(i)
		for j in note_groups[i]:
			popup.add_item(j)
	note_group_option_button.text = note_groups[note_groups.keys()[0]].keys()[0]

func init_root_select_menu(roots: Array) -> void:
	var popup = root_note_option_button.get_popup()
	for idx in range(roots.size()):
		popup.add_item(roots[idx], idx)
	root_note_option_button.text = roots[0]	

func connect_signals():
	var popup = note_group_option_button.get_popup()
	popup.id_pressed.connect(Callable(self, "_on_note_group_selected"))
	
	popup = root_note_option_button.get_popup()
	popup.id_pressed.connect(Callable(self, "_on_root_selected"))

func _on_note_group_selected(id):
	var popup = note_group_option_button.get_popup()
	var selected_item = popup.get_item_text(id)
	note_group_option_button.text = selected_item
	emit_signal("note_group_selected", root_note_option_button.text, selected_item)
	
func _on_root_selected(id):
	var popup = root_note_option_button.get_popup()
	var selected_item = popup.get_item_text(id)
	root_note_option_button.text = selected_item
	emit_signal("note_group_selected", selected_item, note_group_option_button.text)

func _on_play_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		play_button.text = "Stop"
	else:
		play_button.text = "Play"
	
	emit_signal("play", toggled_on)

func _on_bpm_spin_box_value_changed(value: float) -> void:
	emit_signal("bpm_selected", value)

func set_play_button(pressed: bool) -> void:
	play_button.set_pressed(pressed)
