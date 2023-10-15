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

var file_system_box: Control
var file_system_vbox: VBoxContainer
var file_system_hbox: HBoxContainer

var file_system_split: Control
var file_system_vsplit: VSplitContainer
var file_system_hsplit: HSplitContainer

var file_system_box_split_view: Button
var file_system_split_tree: Tree
var file_system_split_item: VBoxContainer
var file_system_split_item_view: ToolButton

## FileSystem Tool button from : `add_control_to_bottom_panel()`
var file_system_button: ToolButton

## Switch
var docked: bool = false


func _enter_tree() -> void:
	# wait until editor fully initialize
	yield(get_tree(), "idle_frame")
	
	# add switch / toggle to control FileSystem docking position
	add_tool_menu_item(TITLE_TOOL_MENU_ITEM, self, "switch_file_system_dock")
	
	# Get file system
	file_system = get_editor_interface().get_file_system_dock()
	file_system_box = file_system.get_child(0) # BoxContainer
	file_system_split = file_system.get_child(3) # SplitContainer
	
	file_system_vbox = file_system.get_child(0)
	file_system_vsplit = file_system.get_child(3)
	
	file_system_hbox = HBoxContainer.new()
	file_system_hsplit = HSplitContainer.new()
	
	file_system_box_split_view = file_system_vbox.get_child(0).get_child(4)
	file_system_split_tree = file_system_vsplit.get_child(0)
	file_system_split_item = file_system_vsplit.get_child(1)
	file_system_split_item_view = file_system_split_item.get_child(0).get_child(2)
	
	#print()
	
	call_deferred("switch_file_system_dock")


func _exit_tree() -> void:
	# remove switch / toggle for FileSystem docking position
	remove_tool_menu_item(TITLE_TOOL_MENU_ITEM)
	
	if !docked:
		return
	
	switch_file_system_dock()


func switch_file_system_dock(_value = null) -> void:
	if _processing:
		return
	_processing = true
	
	if !docked:
		docked = true
		# Move file system to bottom panel
		remove_control_from_docks(file_system)
		file_system_button = add_control_to_bottom_panel(file_system, TITLE)
		file_system.rect_min_size = Vector2.ONE * MIN_SIZE
		
		# Apply new container
		file_system_box.replace_by(file_system_hbox, true)
		file_system_split.replace_by(file_system_hsplit, true)
		
		# Move file button
		file_system_button.get_parent().call_deferred(
				"move_child",
				file_system_button,
				FILE_BUTTON_INDEX
		)
		file_system_button.pressed = true
	
	else:
		docked = false
		# Move file system to left panel
		remove_control_from_bottom_panel(file_system)
		add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, file_system)
		file_system.rect_min_size = Vector2.ONE
		
		# Apply new container
		file_system_box.replace_by(file_system_vbox, true)
		file_system_split.replace_by(file_system_vsplit, true)
	
	# adjustment
	file_system_box_split_view.pressed = docked
	file_system_split_item_view.pressed = !docked
	
	file_system_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	file_system_split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	file_system_split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	file_system_split_tree.size_flags_stretch_ratio = TREE_STRETCH_RATIO
	file_system_split_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	file_system_split_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	for item in file_system_box.get_children():
		item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	_processing = false
