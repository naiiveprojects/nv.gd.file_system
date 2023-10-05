tool
extends EditorPlugin

const TITLE := "File System"
const TITLE_TOOL_MENU_ITEM := "Switch File System Dock"

## Set `FileSytem` rect min size to make it look consisten with other panel. 
const MIN_SIZE := 192 # Convert to Vector2

## Hacky Refrence to the "Split Mode" button on `FileSystem`
const SPLIT_BUTTON_HINT := "Toggle Split Mode"

## relative `TITLE` Button position
const FILE_BUTTON_INDEX := 0

## The Editor FileSystem
var file_system: Control

## FileSystem Tool button from : `add_control_to_bottom_panel()`
var file_system_button: ToolButton

## Box container H/V
var box_container: Control

## split container H/V
var split_container: Control

## Switch
var docked: bool = false

## no race
var _processing: bool = false


func _enter_tree() -> void:
	# wait until editor fully initialize
	yield(get_tree(), "idle_frame")
	
	# add switch / toggle to control FileSystem docking position
	add_tool_menu_item(TITLE_TOOL_MENU_ITEM, self, "switch_file_system_dock")
	
	docked = false
	_processing = false
	switch_file_system_dock()


func _exit_tree() -> void:
	# remove switch / toggle for FileSystem docking position
	remove_tool_menu_item(TITLE_TOOL_MENU_ITEM)
	
	docked = true
	_processing = false
	switch_file_system_dock()


func switch_file_system_dock(_value = null) -> void:
	if _processing:
		return
	
	_processing = true
	
	if !file_system:
		# Get file system
		file_system = get_editor_interface().get_file_system_dock()
		yield(get_tree(), "idle_frame")
		if file_system == null:
			print_debug("Cant Find FileSystemDock")
			_processing = false
			return
	
	if !docked:
		# Move file system to bottom panel
		remove_control_from_docks(file_system)
		
		yield(get_tree(), "idle_frame")
		file_system_button = add_control_to_bottom_panel(file_system, TITLE)
		
		# Setup horizontal container
		box_container = HBoxContainer.new()
		split_container = HSplitContainer.new()
		file_system.rect_min_size = Vector2.ONE * MIN_SIZE
		
		# Move file button
		file_system_button.get_parent().move_child(file_system_button, FILE_BUTTON_INDEX)
		docked = true
	
	else:
		# Move file system to left panel
		remove_control_from_bottom_panel(file_system)
		
		yield(get_tree(), "idle_frame")
		add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, file_system)
		
		# Setup vertical container
		box_container = VBoxContainer.new()
		split_container = VSplitContainer.new()
		file_system.rect_min_size = Vector2.ONE
		
#		yield(get_tree(), "idle_frame")
#		if file_system_button:
#			file_system_button.queue_free()
		docked = false
	
	# Apply new container
	file_system.get_child(0).replace_by(box_container, true)
	file_system.get_child(3).replace_by(split_container, true)
	
	# Readjust the tree and item list
	var split_button: Button = box_container.get_child(0).get_child(4)
	var file_tree: Tree = split_container.get_child(0)
	var file_item: VBoxContainer = split_container.get_child(1)
	var item_view: ToolButton = file_item.get_child(0).get_child(2)
	
	split_button.visible = !docked
	split_button.pressed = docked
	item_view.pressed = !docked
	
	# Container adjustment
	file_tree.size_flags_stretch_ratio = 0.2
	file_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	file_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	box_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	for item in box_container.get_children():
		item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	_processing = false
