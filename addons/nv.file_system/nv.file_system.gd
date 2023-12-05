@tool
extends EditorPlugin

const TITLE := "File System"
const TITLE_TOOL_MENU_ITEM := "Switch File System Dock"

## Set `FileSytem` rect min size to make it look consisten with other panel. 
const MIN_SIZE := 192 # Convert to Vector2

const TREE_STRETCH_RATIO := 0.25

## relative `TITLE` Button position
const FILE_BUTTON_INDEX := 0

## no race
var _processing: bool = false
var docked: bool = false

## The Editor FileSystem
var file_system: FileSystemDock
var file_system_box: BoxContainer
var file_system_split: SplitContainer
var file_system_vbox: BoxContainer
var file_system_hbox: BoxContainer
var file_system_vsplit: SplitContainer
var file_system_hsplit: SplitContainer
var file_system_split_view: Button
var file_system_tree: Tree
var file_system_item: VBoxContainer
var file_system_item_view: Button

## Box container H/V
var box_container: BoxContainer

## split container H/V
var split_container: SplitContainer

## Tool button from : `add_control_to_bottom_panel()`
var tool_button: Button
var submenu_item: PopupMenu


func _enter_tree() -> void:
	## ------- CUSTOMIZE SHORTCUT ------- ##
	var shortcut := InputEventKey.new()
	shortcut.alt_pressed = true
	shortcut.keycode = KEY_S
	## ------- CUSTOMIZE SHORTCUT ------- ##
	
	# add switch / toggle to control FileSystem docking position
	submenu_item = PopupMenu.new()
	submenu_item.add_item(
			TITLE_TOOL_MENU_ITEM,
			0,
			shortcut.get_keycode_with_modifiers()
	)
	submenu_item.index_pressed.connect(switch_file_system_dock)
	
	add_tool_submenu_item(TITLE, submenu_item)
	
	# wait until editor fully initialize
	await get_tree().process_frame
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
	file_system_item_view = file_system_item.get_child(0).get_child(2)
	
	switch_file_system_dock()


func _exit_tree() -> void:
	# remove switch / toggle for FileSystem docking position
	remove_tool_menu_item(TITLE)
	
	if !docked:
		return
	
	## Duplicate since we cannot call function successfully when exit tree.
	
	# Move file system to left panel
	remove_control_from_bottom_panel(file_system)
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, file_system)
	
	# Setup vertical container
	box_container = file_system_vbox
	split_container = file_system_vsplit
	file_system.custom_minimum_size = Vector2.ONE
	
	# Refrences
	file_system_box = file_system.get_child(0) # BoxContainer
	file_system_split = file_system.get_child(3) # SplitContainer
	
	# Apply new container
	file_system_box.replace_by(box_container, true)
	file_system_split.replace_by(split_container, true)
	
	# adjustment
	file_system_split_view.button_pressed = false
	file_system_item_view.button_pressed = false
	
	file_system_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	file_system_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	box_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	for item in box_container.get_children():
		item.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func switch_file_system_dock(_value = null) -> void:
	if _processing:
		return
	
	_processing = true
	
	if !docked:
		docked = true
		# Move file system to bottom panel
		remove_control_from_docks(file_system)
		tool_button = add_control_to_bottom_panel(file_system, TITLE)
		
		# Setup horizontal container
		box_container = file_system_hbox
		split_container = file_system_hsplit
		file_system.custom_minimum_size = Vector2.ONE * MIN_SIZE
		
		# Move file button
		tool_button.get_parent().move_child(tool_button, FILE_BUTTON_INDEX)
		tool_button.button_pressed = true
	
	else:
		docked = false
		# Move file system to left panel
		remove_control_from_bottom_panel(file_system)
		add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, file_system)
		
		# Setup vertical container
		box_container = file_system_vbox
		split_container = file_system_vsplit
		file_system.custom_minimum_size = Vector2.ONE
	
	# Apply new container
	file_system_box.replace_by(box_container, true)
	file_system_split.replace_by(split_container, true)
	file_system_box = box_container
	file_system_split = split_container
	
	# make sure changes has been apply before continue
	await get_tree().process_frame
	
	# adjustment
	file_system_split_view.button_pressed = docked
	file_system_item_view.button_pressed = !docked
	
	file_system_tree.size_flags_stretch_ratio = TREE_STRETCH_RATIO
	file_system_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	file_system_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	box_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	for item in box_container.get_children():
		item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	_processing = false
