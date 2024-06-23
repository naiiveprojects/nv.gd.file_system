# warning-ignore-all: RETURN_VALUE_DISCARDED

tool
extends EditorPlugin

const TITLE := "File System"
const TITLE_TOOL_MENU_SWITCH := "Switch File System Dock"
const TITLE_TOOL_MENU_SHOW := "Show/Hide File System Dock (Bottom Dock)"
const DATA_PATH := "res://addons/nv.file_system/config.cfg"

## Set `FileSytem` rect min size to make it look consisten with other panel. 
const MIN_SIZE := Vector2.ONE * 320
const TREE_STRETCH_RATIO := 0.25

## relative `TITLE` Button position
const FILE_BUTTON_INDEX := 0

var _switching: bool = false
var docked: bool = false

var config := { "docked" : true }


## The Editor FileSystem
var file_system: FileSystemDock
var file_system_box: BoxContainer
var file_system_split: SplitContainer
var file_system_vbox: VBoxContainer
var file_system_hbox: HBoxContainer
var file_system_vsplit: VSplitContainer
var file_system_hsplit: HSplitContainer
var file_system_split_view: Button
var file_system_tree: Tree
var file_system_item: VBoxContainer
var file_system_origin: Control

## container H/V
var box_container: BoxContainer
var split_container: SplitContainer

## Tool button from : `add_control_to_bottom_panel()`
var tool_button: ToolButton
var submenu_item: PopupMenu


func _enter_tree() -> void:
	## ------- CUSTOMIZE SHORTCUT ------- ##
	var shortcut_switch := InputEventKey.new()
	shortcut_switch.alt = true
	shortcut_switch.scancode = KEY_S
	
	var shortcut_show := InputEventKey.new()
	shortcut_show.control = true
	shortcut_show.scancode = KEY_SPACE
	## ------- CUSTOMIZE SHORTCUT ------- ##
	
	# add switch / toggle to control FileSystem docking position
	submenu_item = PopupMenu.new()
	submenu_item.add_item(
			TITLE_TOOL_MENU_SWITCH,
			0,
			shortcut_switch.get_scancode_with_modifiers()
	)
	submenu_item.add_item(
			TITLE_TOOL_MENU_SHOW,
			1,
			shortcut_show.get_scancode_with_modifiers()
	)
	submenu_item.connect(
			"index_pressed",
			self,
			"switch_file_system_dock"
	)
	
	add_tool_submenu_item(TITLE, submenu_item)
	
	# wait until editor fully initialize
	yield(get_tree(), "idle_frame")
	file_system = get_editor_interface().get_file_system_dock()
	
	# Create references
	file_system_box = file_system.get_child(0) # BoxContainer
	file_system_split = file_system.get_child(3) # SplitContainer
	
	file_system_hbox = HBoxContainer.new()
	file_system_hsplit = HSplitContainer.new()
	file_system_vbox = file_system_box
	file_system_vsplit = file_system_split
	
	file_system_tree = file_system_vsplit.get_child(0)
	file_system_item = file_system_vsplit.get_child(1)
	file_system_split_view = file_system_vbox.get_child(0).get_child(4)
	file_system_split_view.connect("toggled", self, "_split_view_toggled")
	
	load_config()


func _exit_tree() -> void:
	# remove switch / toggle for FileSystem docking position
	remove_tool_menu_item(TITLE)
	
	# Saving
	config.docked = docked
	save_config()
	
	if !docked:
		return
	
	## Duplicate since we cannot call function successfully when exit tree.
	
	# Move file system to left panel
	remove_control_from_bottom_panel(file_system)
	file_system_origin.add_child(file_system)
	
	# Setup vertical container
	box_container = file_system_vbox
	split_container = file_system_vsplit
	file_system.rect_min_size = Vector2.ONE
	
	# Refrences
	file_system_box = file_system.get_child(0) # BoxContainer
	file_system_split = file_system.get_child(3) # SplitContainer
	
	# Apply new container
	file_system_box.replace_by(box_container, true)
	file_system_split.replace_by(split_container, true)
	
	# adjustment
	file_system_split_view.pressed = false
	
	file_system_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	file_system_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	box_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	for item in box_container.get_children():
		item.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func load_config() -> void:
	var cfg := ConfigFile.new()
	var err = cfg.load(DATA_PATH)
	
	if err != OK:
		switch_file_system_dock()
		return
	
	for item in config.keys():
		config[item] = cfg.get_value(TITLE, item, config.get(item))
	
	if config.docked != docked:
		switch_file_system_dock()


func save_config() -> void:
	var cfg := ConfigFile.new()
	
	for item in config.keys():
		cfg.set_value(TITLE, item, config.get(item))
	
	cfg.save(DATA_PATH)


func switch_file_system_dock(value: int = OK) -> void:
	if _switching:
		return
	
	if value != OK:
		if docked:
			tool_button.pressed = !tool_button.pressed 
		return
	
	_switching = true
	
	if !docked:
		docked = true
		file_system_origin = file_system.get_parent()
		
		# Move file system to bottom panel
		remove_control_from_docks(file_system)
		tool_button = add_control_to_bottom_panel(file_system, TITLE)
		
		# Setup horizontal container
		box_container = file_system_hbox
		split_container = file_system_hsplit
		file_system.rect_min_size = MIN_SIZE
		
		# Move file button
		tool_button.get_parent().move_child(tool_button, FILE_BUTTON_INDEX)
		
		# Show File System immediately
		tool_button.pressed = true
	
	else:
		docked = false
		# Move file system to left panel
		remove_control_from_bottom_panel(file_system)
		file_system_origin.add_child(file_system)
		
		# Setup vertical container
		box_container = file_system_vbox
		split_container = file_system_vsplit
		file_system.rect_min_size = Vector2.ONE
	
	# Apply new container
	file_system_box.replace_by(box_container, true)
	file_system_split.replace_by(split_container, true)
	file_system_box = box_container
	file_system_split = split_container
	
	# make sure changes has been apply before continue
	yield(get_tree(), "idle_frame")
	
	# adjustment
	file_system_split_view.pressed = docked
	
	file_system_tree.size_flags_stretch_ratio = TREE_STRETCH_RATIO
	file_system_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	file_system_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	box_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	for item in box_container.get_children():
		item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	_switching = false


func _split_view_toggled(value: bool) -> void:
	if value != docked:
		switch_file_system_dock()
