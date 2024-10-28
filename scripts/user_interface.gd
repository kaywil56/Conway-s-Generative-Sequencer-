extends Control
signal note_group_selected(root, note_group)
signal play(toggled)

@onready var root_note_option_button = $TopBarHBoxContainer/NoteGroupSelectionHBoxContainer/RootNoteOptionButton
@onready var note_group_option_button = $TopBarHBoxContainer/NoteGroupSelectionHBoxContainer/NoteGroupOptionButton
@onready var play_button = $TopBarHBoxContainer/PlayButton

func _ready() -> void:
	connect_signals()

func init_note_group_menu(note_groups: Array) -> void:
	var popup = note_group_option_button.get_popup()
	for idx in range(note_groups.size()):
		popup.add_item(note_groups[idx], idx)
	
	note_group_option_button.text = note_groups[0]

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
