tool
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

## The Editor FileSystem
var file_system: FileSystemDock
var file_system_head: Control
var file_system_body: Control
var file_system_split_view: Button
var file_system_tree: Tree
var file_system_item: VBoxContainer
var file_system_item_view: ToolButton

## FileSystem Tool button from : `add_control_to_bottom_panel()`
var file_system_button: ToolButton

## Box container H/V
var box_container: Control

## split container H/V
var split_container: Control

var submenu_item: PopupMenu

## Switch
var docked: bool = false


func _enter_tree() -> void:
	## ------- CUSTOMIZE SHORTCUT ------- ##
	var shortcut := InputEventKey.new()
	shortcut.alt = true
	shortcut.scancode = KEY_S
	## ------- CUSTOMIZE SHORTCUT ------- ##
	
	# add switch / toggle to control FileSystem docking position
	submenu_item = PopupMenu.new()
	submenu_item.add_item(
			TITLE_TOOL_MENU_ITEM,
			0,
			shortcut.get_scancode_with_modifiers()
	)
	submenu_item.connect(
			"index_pressed",
			self,
			"switch_file_system_dock"
	)
	
	add_tool_submenu_item(TITLE, submenu_item)
	
	# wait until editor fully initialize
	yield(get_tree(), "idle_frame")
	switch_file_system_dock()


func _exit_tree() -> void:
	# remove switch / toggle for FileSystem docking position
	remove_tool_menu_item(TITLE)
	
	if !docked:
		return
	
	# Move file system to left panel
	remove_control_from_bottom_panel(file_system)
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, file_system)
	
	# Setup vertical container
	box_container = VBoxContainer.new()
	split_container = VSplitContainer.new()
	file_system.rect_min_size = Vector2.ONE
	
	# Refrences
	file_system_head = file_system.get_child(0) # BoxContainer
	file_system_body = file_system.get_child(3) # SplitContainer
	# Apply new container
	file_system_head.replace_by(box_container, true)
	file_system_body.replace_by(split_container, true)
	
	# Child Node Refrences
	file_system_split_view = box_container.get_child(0).get_child(4)
	file_system_tree = split_container.get_child(0)
	file_system_item = split_container.get_child(1)
	file_system_item_view = file_system_item.get_child(0).get_child(2)
	
	# adjustment
	file_system_split_view.pressed = false
	file_system_item_view.pressed = false
	
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
	
	# Get file system
	file_system = get_editor_interface().get_file_system_dock()
	
	if !docked:
		docked = true
		# Move file system to bottom panel
		remove_control_from_docks(file_system)
		file_system_button = add_control_to_bottom_panel(file_system, TITLE)
		
		# Setup horizontal container
		box_container = HBoxContainer.new()
		split_container = HSplitContainer.new()
		file_system.rect_min_size = Vector2.ONE * MIN_SIZE
		
		# Move file button
		file_system_button.get_parent().move_child(file_system_button, FILE_BUTTON_INDEX)
		file_system_button.pressed = true
	
	else:
		docked = false
		# Move file system to left panel
		remove_control_from_bottom_panel(file_system)
		add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, file_system)
		
		# Setup vertical container
		box_container = VBoxContainer.new()
		split_container = VSplitContainer.new()
		file_system.rect_min_size = Vector2.ONE
	
	# Refrences
	file_system_head = file_system.get_child(0) # BoxContainer
	file_system_body = file_system.get_child(3) # SplitContainer
	
	# Apply new container
	file_system_head.replace_by(box_container, true)
	file_system_body.replace_by(split_container, true)
	
	yield(get_tree(), "idle_frame")
	if split_container.get_child(0) != Tree:
		yield(get_tree(), "idle_frame")
	
	# Child Node Refrences
	file_system_tree = split_container.get_child(0)
	file_system_item = split_container.get_child(1)
	file_system_split_view = box_container.get_child(0).get_child(4)
	file_system_item_view = file_system_item.get_child(0).get_child(2)
	
	# adjustment
	file_system_split_view.pressed = docked
	file_system_item_view.pressed = !docked
	
	file_system_tree.size_flags_stretch_ratio = TREE_STRETCH_RATIO
	file_system_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	file_system_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	box_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	for item in box_container.get_children():
		item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	_processing = false
