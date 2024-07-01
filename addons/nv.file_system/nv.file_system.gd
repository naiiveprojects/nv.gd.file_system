@tool
extends EditorPlugin

enum { SWITCH, TOGGLE }

const TITLE: String = "File System"
const TITLE_TOOL_MENU_SWITCH: String = "Switch File System Dock"
const TITLE_TOOL_MENU_SHOW: String = "Show/Hide File System Dock (Bottom Dock)"
const PATH_CONFIG: String = "res://addons/nv.file_system/config.cfg"
const SPLIT_BUTTON_STATE_MAX: int = 3
const MIN_SIZE: Vector2i = Vector2i.ONE * 320
const FILE_BUTTON_INDEX: int = 0

var _switching: bool = false
var config :Dictionary = { "docked" : true }

var file_system: FileSystemDock = get_editor_interface().get_file_system_dock()
var file_system_split: SplitContainer = file_system.get_child(3)
var file_system_item: VBoxContainer = file_system_split.get_child(1)
var file_system_split_view: Button = file_system.get_child(0).get_child(0).get_child(4)
var file_system_dock: TabContainer
var tool_button: Button
var submenu_item: PopupMenu


func _enter_tree() -> void:
	await get_tree().process_frame
	var unit: Dictionary = {
			'FileSystem': file_system,
			'SplitContainer:3': file_system_split,
			'VBoxContainer:3.1': file_system_item,
			'SplitModeButton:0.0.4': file_system_split_view,
	}
	for u in unit.keys(): if unit[u] == null:
		print('{}\n{}{}'.format(['nv.file_system', "Missing : ", u], '{}'))
		return
	
	for node in file_system_split.get_children():
		node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	file_system_split.get_child(0).size_flags_stretch_ratio = 0.25
	file_system.display_mode_changed.connect(_display_mode_changed)
	
	create_shortcuts()
	load_config()


func _exit_tree() -> void:
	var docked := is_docked()
	config.docked = docked
	
	save_config()
	remove_tool_menu_item(TITLE)
	
	if !docked: return
	remove_control_from_bottom_panel(file_system)
	file_system_dock.add_child(file_system)
	file_system.custom_minimum_size = Vector2.ONE


func _switch_file_system_dock(value: int = SWITCH) -> void:
	if _switching: return
	
	if value != SWITCH:
		if is_docked():
			tool_button.button_pressed = !tool_button.button_pressed 
		return
	
	_switching = true
	
	if !is_docked():
		file_system_dock = file_system.get_parent()
		
		remove_control_from_docks(file_system)
		tool_button = add_control_to_bottom_panel(file_system, TITLE)
		file_system.custom_minimum_size = MIN_SIZE
		
		tool_button.get_parent().move_child(tool_button, FILE_BUTTON_INDEX)
		tool_button.button_pressed = true
		
		for i in SPLIT_BUTTON_STATE_MAX:
			if file_system_split.vertical or !file_system_item.visible:
				file_system_split_view.pressed.emit()
				await get_tree().process_frame
				continue
			break
	
	else:
		if file_system_item.visible:
			file_system_split_view.pressed.emit()
		
		remove_control_from_bottom_panel(file_system)
		file_system_dock.add_child(file_system)
		file_system.custom_minimum_size = Vector2.ONE
	
	_switching = false


func _display_mode_changed() -> void:
	if !file_system_split.vertical and file_system_item.visible:
		_switch_file_system_dock()
	elif is_docked() and !file_system_item.visible:
		_switch_file_system_dock()


func is_docked() -> bool:
	return weakref(tool_button).get_ref() != null


func create_shortcuts() -> void:
	## ------- CUSTOMIZE SHORTCUT ------- ##
	var shortcut_switch := InputEventKey.new()
	shortcut_switch.alt_pressed = true
	shortcut_switch.keycode = KEY_S
	
	var shortcut_show := InputEventKey.new()
	shortcut_show.ctrl_pressed = true
	shortcut_show.keycode = KEY_SPACE
	
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
	submenu_item.index_pressed.connect(_switch_file_system_dock)
	add_tool_submenu_item(TITLE, submenu_item)


func load_config() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH_CONFIG) != OK:
		_switch_file_system_dock()
		return
	
	for item in config.keys():
		config[item] = cfg.get_value(TITLE, item, config.get(item))
	if config.docked != is_docked():
		_switch_file_system_dock()


func save_config() -> void:
	var cfg := ConfigFile.new()
	for item in config.keys():
		cfg.set_value(TITLE, item, config.get(item))
	cfg.save(PATH_CONFIG)


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░ Title: NV File System
# ░░█▀█░█▀█░█░░░█░░░█░█░█▀▀░░ Act: bottom panel FileSystem
# ░░█░█░█▀█░░▀▄░░▀▄░▀▄▀░█▀▀░░ Cast[ Editor, FileSystem ]
# ░░▀░▀░▀░▀░░░▀░░░▀░░▀░░▀▀▀░░ Writters[ @illlustr, ]
# ░ Projects ░░░░░░░░░░░░░░░░ https://github.com/naiiveprojects
