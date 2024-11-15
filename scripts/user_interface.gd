extends Control
signal note_group_selected(root, note_group)
signal octave_changed(min_octave, max_octave)
signal play(toggled)
signal bpm_selected(bpm)
signal seed_selected(seed)
signal randomize_probability
signal grid_width_selected(width)
signal grid_height_selected(height)
signal offset_selected(offset)

@onready var root_note_menu_button = $TopBarVBoxContainer/SettingsBarHBoxContainer/RootNoteVBoxContainer/RootNoteMenuButton
@onready var chords_and_scales_menu_button = $TopBarVBoxContainer/SettingsBarHBoxContainer/ChordsAndScalesVBoxContainer/ChordsAndScalesMenuButton
@onready var play_button = $TopBarVBoxContainer/PlayButton
@onready var seed_select_menu_button = $TopBarVBoxContainer/SettingsBarHBoxContainer/SeedSelectHBoxContainer/SeedSelectMenuButton
@onready var min_octave_spinbox  = $TopBarVBoxContainer/SettingsBarHBoxContainer/OctaveRangeVBoxContainer/OctaveRangeSpinboxHBoxContainer/MinOctaveRangeSpinBox
@onready var max_octave_spinbox = $TopBarVBoxContainer/SettingsBarHBoxContainer/OctaveRangeVBoxContainer/OctaveRangeSpinboxHBoxContainer/MaxOctaveRangeSpinbox
@onready var bpm_spinbox = $TopBarVBoxContainer/SettingsBarHBoxContainer/BpmVBoxContainer/BpmSpinBox
@onready var grid_width_option_button = $TopBarVBoxContainer/SettingsBarHBoxContainer/GridWidthVBoxContainer/GridWidthOptionButton
@onready var grid_height_option_button = $TopBarVBoxContainer/SettingsBarHBoxContainer/GridHeightVBoxContainer/GridHeightOptionButton
@onready var offset_menu_button = $TopBarVBoxContainer/SettingsBarHBoxContainer/OffsetVBoxContainer/OffsetMenuButton

func _ready() -> void:
	connect_signals()
	init_grid_width_menu()
	init_grid_height_menu()
	init_offset_menu()
	
func set_octave(min_octave: int, max_octave: int) -> void:
	min_octave_spinbox.value = min_octave
	max_octave_spinbox.value = max_octave
	
func init_grid_width_menu() -> void:
	var popup = grid_width_option_button.get_popup()
	var widths = [4, 8, 16]
	for i in widths:
		var value = str(i) + " Bars"
		popup.add_item(value)
	grid_width_option_button.text = popup.get_item_text(2)

func init_grid_height_menu() -> void:
	var popup = grid_height_option_button.get_popup()
	for i in range(1, 5):
		var value = str(i) + "x"
		popup.add_item(value)
	var popup_item_text = popup.get_item_text(1)
	grid_height_option_button.text = popup_item_text

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

func init_seed_select_menu(seeds: Array) -> void:
	var popup = seed_select_menu_button.get_popup()
	for idx in range(seeds.size()):
		popup.add_item(seeds[idx], idx)
	seed_select_menu_button.text = seeds[0]

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
	
	popup = seed_select_menu_button.get_popup()
	popup.id_pressed.connect(Callable(self, "_on_seed_selected"))
	
	popup = grid_width_option_button.get_popup()
	popup.id_pressed.connect(Callable(self, "_on_grid_width_selected"))
	
	popup = grid_height_option_button.get_popup()
	popup.id_pressed.connect(Callable(self, "_on_grid_height_selected"))
	
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

func _on_grid_width_selected(id: int) -> void:
	var popup = grid_width_option_button.get_popup()
	var selected_item = popup.get_item_text(id)
	grid_width_option_button.text = selected_item
	emit_signal("grid_width_selected", selected_item)
	
func _on_grid_height_selected(id: int) -> void:
	var popup = grid_height_option_button.get_popup()
	var selected_item = popup.get_item_text(id)
	grid_height_option_button.text = selected_item
	emit_signal("grid_height_selected", selected_item)

func get_grid_height() -> String:
	return grid_height_option_button.text

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
