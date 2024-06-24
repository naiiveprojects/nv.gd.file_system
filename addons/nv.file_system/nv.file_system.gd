# warning-ignore-all: RETURN_VALUE_DISCARDED

@tool
extends EditorPlugin

enum { SWITCH, TOGGLE }

const TITLE: String = "File System"
const TITLE_TOOL_MENU_SWITCH: String = "Switch File System Dock"
const TITLE_TOOL_MENU_SHOW: String = "Show/Hide File System Dock (Bottom Dock)"
const PATH_CONFIG: String = "res://addons/nv.file_system/config.cfg"
const SPLIT_BUTTON_STATE_MAX: int = 3

## Set `FileSytem` rect min size to make it look consisten with other panel. 
const MIN_SIZE: Vector2i = Vector2i.ONE * 320

## relative `TITLE` Button position
const FILE_BUTTON_INDEX: int = 0

var config :Dictionary = { "docked" : true }
var _switching: bool = false
var docked: bool = false

## The Editor FileSystem
var file_system: FileSystemDock
var file_system_vsplit: SplitContainer
var file_system_item: VBoxContainer
var file_system_split_view: Button
var file_system_origin: Control

## Tool button from : `add_control_to_bottom_panel()`
var tool_button: Button
var submenu_item: PopupMenu


func _enter_tree() -> void:
	# wait until editor fully initialize
	await get_tree().process_frame
	
	## ------- CUSTOMIZE SHORTCUT ------- ##
	var shortcut_switch := InputEventKey.new()
	shortcut_switch.alt_pressed = true
	shortcut_switch.keycode = KEY_S
	
	var shortcut_show := InputEventKey.new()
	shortcut_show.ctrl_pressed = true
	shortcut_show.keycode = KEY_SPACE
	## ------- CUSTOMIZE SHORTCUT ------- ##
	
	# add switch / toggle to control FileSystem docking position
	submenu_item = PopupMenu.new()
	submenu_item.add_item(
			TITLE_TOOL_MENU_SWITCH,
			SWITCH,
			shortcut_switch.get_keycode_with_modifiers()
	)
	submenu_item.add_item(
			TITLE_TOOL_MENU_SHOW,
			TOGGLE,
			shortcut_show.get_keycode_with_modifiers()
	)
	submenu_item.index_pressed.connect(switch_file_system_dock)
	
	add_tool_submenu_item(TITLE, submenu_item)
	
	# wait until editor fully initialize
	await get_tree().process_frame
	
	# Create references
	file_system = get_editor_interface().get_file_system_dock()
	file_system_vsplit = file_system.get_child(3)
	file_system_item = file_system_vsplit.get_child(1)
	file_system_split_view = file_system.get_child(0).get_child(0).get_child(4)
	
	var unit: Dictionary = {
			'FileSystem': file_system,
			'VSplitContainer:3': file_system_vsplit,
			'VBoxContainer:3.1': file_system_item,
			'SplitModeButton:0.0.4': file_system_split_view,
	}
	
	for u in unit.keys():
		if unit[u] == null:
			print('{}\n{}{}'.format(['nv.file_system', "Failed Creating a reference for : ", u], '{}'))
			return
	
	for node in file_system_vsplit.get_children():
		node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	file_system_vsplit.get_child(0).size_flags_stretch_ratio = 0.25
	
	file_system.display_mode_changed.connect(_display_mode_changed)
	
	await get_tree().process_frame
	load_config()


func _exit_tree() -> void:
	# remove switch / toggle for FileSystem docking position
	remove_tool_menu_item(TITLE)
	
	# Saving
	config.docked = docked
	save_config()
	
	if !docked: return
	
	# Move file system to last known tab
	remove_control_from_bottom_panel(file_system)
	file_system_origin.add_child(file_system)
	file_system.custom_minimum_size = Vector2.ONE


func load_config() -> void:
	var cfg := ConfigFile.new()
	var err = cfg.load(PATH_CONFIG)
	
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
	
	cfg.save(PATH_CONFIG)


func switch_file_system_dock(value: int = SWITCH) -> void:
	if _switching: return
	
	if value != SWITCH:
		if docked:
			tool_button.button_pressed = !tool_button.button_pressed 
		return
	
	_switching = true
	
	if !docked:
		docked = true
		file_system_origin = file_system.get_parent()
		
		for i in SPLIT_BUTTON_STATE_MAX:
			if file_system_vsplit.vertical or !file_system_item.visible:
				file_system_split_view.pressed.emit()
				await get_tree().process_frame
				continue
			break
		
		# Move file system to bottom panel
		remove_control_from_docks(file_system)
		tool_button = add_control_to_bottom_panel(file_system, TITLE)
		file_system.custom_minimum_size = MIN_SIZE
		
		# Move file button
		tool_button.get_parent().move_child(tool_button, FILE_BUTTON_INDEX)
		tool_button.button_pressed = true
	
	else:
		docked = false
		
		if file_system_item.visible:
			file_system_split_view.pressed.emit()
		
		# Move file system to last known tab
		remove_control_from_bottom_panel(file_system)
		file_system_origin.add_child(file_system)
		file_system.custom_minimum_size = Vector2.ONE
	
	_switching = false


func _display_mode_changed() -> void:
	if !file_system_vsplit.vertical and file_system_item.visible:
		switch_file_system_dock()
	elif docked and !file_system_item.visible:
		switch_file_system_dock()
