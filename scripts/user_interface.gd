extends Control
signal note_group_selected(root, note_group)
signal octave_changed(min_octave, max_octave)
signal play(toggled)
signal bpm_selected(bpm)
signal seed_selected(seed)
signal randomize_probability
signal reset_probability
signal offset_selected(offset)
signal port_selected

@onready var root_note_menu_button = $ShellVBoxContainer/SideBarPanelContainer/SideBarVBoxContainer/SideBarGridContainer/RootNoteVBoxContainer/RootNoteMenuButton
@onready var chords_and_scales_menu_button = $ShellVBoxContainer/SideBarPanelContainer/SideBarVBoxContainer/SideBarGridContainer/ChordsAndScalesVBoxContainer/ChordsAndScalesMenuButton
@onready var play_button = $ShellVBoxContainer/SideBarPanelContainer/SideBarVBoxContainer/HBoxContainer/PlayButton
@onready var seed_select_menu_button = $ShellVBoxContainer/SideBarPanelContainer/SideBarVBoxContainer/SideBarGridContainer/SeedSelectHBoxContainer/SeedSelectMenuButton
@onready var min_octave_spinbox  = $ShellVBoxContainer/SideBarPanelContainer/SideBarVBoxContainer/SideBarGridContainer/OctaveRangeVBoxContainer/OctaveRangeSpinboxHBoxContainer/MinOctaveRangeSpinBox
@onready var max_octave_spinbox = $ShellVBoxContainer/SideBarPanelContainer/SideBarVBoxContainer/SideBarGridContainer/OctaveRangeVBoxContainer/OctaveRangeSpinboxHBoxContainer/MaxOctaveRangeSpinbox
@onready var bpm_spinbox = $ShellVBoxContainer/SideBarPanelContainer/SideBarVBoxContainer/SideBarGridContainer/BpmVBoxContainer/BpmSpinBox
@onready var offset_menu_button = $ShellVBoxContainer/SideBarPanelContainer/SideBarVBoxContainer/SideBarGridContainer/OffsetVBoxContainer/OffsetMenuButton
@onready var midi_port_item_list = $ShellVBoxContainer/SideBarPanelContainer/SideBarVBoxContainer/MidiPortVBoxContainer/MidiPortItemList
@onready var side_bar_panel = $ShellVBoxContainer/SideBarPanelContainer

func _ready() -> void:
	connect_signals()
	midi_port_item_list.set_auto_height(true)
	init_offset_menu()
	var children = get_children()
	disable_focus(children)
	
func disable_focus(children):
	for child in children:
		if child is SpinBox:
			var line_edit: LineEdit = child.get_line_edit()
			line_edit.focus_mode = FOCUS_NONE
			line_edit.selecting_enabled = false
			line_edit.mouse_default_cursor_shape = Control.CURSOR_ARROW
		child.focus_mode = FOCUS_NONE
		if child.get_child_count() > 0:
			disable_focus(child.get_children())

func get_side_bar_width() -> float:
	return side_bar_panel.get_rect().size.x

func set_octave(min_octave: int, max_octave: int) -> void:
	min_octave_spinbox.value = min_octave
	max_octave_spinbox.value = max_octave
	
func init_note_group_menu(note_groups: Dictionary) -> void:
	var popup = chords_and_scales_menu_button.get_popup()
	for i in note_groups:
		popup.add_separator(i)
		for j in note_groups[i]:
			popup.add_item(j)
	chords_and_scales_menu_button.text = note_groups[note_groups.keys()[0]].keys()[0]

func init_root_select_menu(roots: Array) -> void:
	var popup = root_note_menu_button.get_popup()
	for idx in range(roots.size()):
		popup.add_item(roots[idx], idx)
	root_note_menu_button.text = roots[0]	

func set_midi_port_item_list(ports) -> void:
	print(ports)
	midi_port_item_list.clear()
	for idx in range(ports.size()):
		midi_port_item_list.add_item(ports[idx])

func init_offset_menu():
	var popup = offset_menu_button.get_popup()
	var offsets = [
		"None",
		"1/64th",
		"1/32th",
		"1/16th",
		"1/8th",
		"1/4th",
		"1/2th",
	]
	for offset in offsets:
		popup.add_item(offset)
	var popup_item_text = popup.get_item_text(0)
	offset_menu_button.text = popup_item_text

func connect_signals():
	var popup = chords_and_scales_menu_button.get_popup()
	popup.id_pressed.connect(Callable(self, "_on_note_group_selected"))
	
	popup = root_note_menu_button.get_popup()
	popup.id_pressed.connect(Callable(self, "_on_root_selected"))
		
	popup = offset_menu_button.get_popup()
	popup.id_pressed.connect(Callable(self, "_on_offset_selected"))

func _on_offset_selected(id):
	var popup = offset_menu_button.get_popup()
	var selected_item = popup.get_item_text(id)
	offset_menu_button.text = selected_item
	emit_signal("offset_selected", selected_item)
	
func _on_note_group_selected(id):
	var popup = chords_and_scales_menu_button.get_popup()
	var selected_item = popup.get_item_text(id)
	chords_and_scales_menu_button.text = selected_item
	emit_signal("note_group_selected", root_note_menu_button.text, selected_item)
	
func _on_root_selected(id):
	var popup = root_note_menu_button.get_popup()
	var selected_item = popup.get_item_text(id)
	root_note_menu_button.text = selected_item
	emit_signal("note_group_selected", selected_item, chords_and_scales_menu_button.text)
	
func _on_seed_selected(id):
	var popup = seed_select_menu_button.get_popup()
	var selected_item = popup.get_item_text(id)
	seed_select_menu_button.text = selected_item
	emit_signal("seed_selected", selected_item)

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

func _on_randomize_probability_button_pressed() -> void:
	emit_signal("randomize_probability")

func _on_min_octave_range_spin_box_value_changed(value: float) -> void:
	print("test")
	if max_octave_spinbox.value == value:
		min_octave_spinbox.value = value - 1
	else:
		emit_signal("octave_changed", value, max_octave_spinbox.value)
	
func _on_max_octave_range_spinbox_value_changed(value: float) -> void:
	if min_octave_spinbox.value == value:
		max_octave_spinbox.value = value + 1
	else:
		emit_signal("octave_changed", min_octave_spinbox.value, value)

func _on_reset_probability_button_pressed() -> void:
	emit_signal("reset_probability")

func _on_midi_port_refresh_button_pressed() -> void:
	emit_signal("refresh_midi_ports")

func _on_midi_port_item_list_item_selected(index: int) -> void:
	emit_signal("port_selected", index)

func _on_clear_seed_button_pressed() -> void:
	emit_signal("seed_selected", "Blank")

func _on_random_seed_button_pressed() -> void:
	emit_signal("seed_selected", "Random")
