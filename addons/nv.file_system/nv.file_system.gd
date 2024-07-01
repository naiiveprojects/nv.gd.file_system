tool
extends EditorPlugin

enum { SWITCH, VISIBLE }

const TITLE := 'File System'
const TITLE_TOOL_MENU_SWITCH := 'Switch File System Dock'
const TITLE_TOOL_MENU_SHOW := 'Show/Hide File System Dock (Bottom Dock)'
const PATH_CONFIG := 'res://addons/nv.file_system/config.cfg'
const MIN_SIZE := Vector2.ONE * 320

var _switching: bool = false
var config := { "docked" : true }

var file_system: FileSystemDock = get_editor_interface().get_file_system_dock()
var file_system_vsplit: VSplitContainer = file_system.get_child(3)
var file_system_hsplit: HSplitContainer = HSplitContainer.new()
var file_system_split_view: Button = file_system.get_child(0).get_child(0).get_child(4)
var file_system_split: SplitContainer = file_system_vsplit
var file_system_dock: TabContainer
var file_system_tree: Tree = file_system_split.get_child(0)
var file_system_item: VBoxContainer = file_system_split.get_child(1)
var tool_button: ToolButton
var split_container: SplitContainer


func _enter_tree() -> void:
	yield(get_tree(), "idle_frame")
	var units := [
			file_system_hsplit, file_system_vsplit,
			file_system_tree, file_system_item
	]
	for unit in units:
		if unit != null:
			unit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			unit.size_flags_vertical = Control.SIZE_EXPAND_FILL
			continue
		print('- nv.file_system\n-> failed creating a reference')
		return
	
	file_system_tree.size_flags_stretch_ratio = 0.25
	file_system_split_view.connect("toggled", self, "_split_view_toggled")
	
	create_shortcut()
	load_config()


func _exit_tree() -> void:
	remove_tool_menu_item(TITLE)
	
	config.docked = file_system_hsplit.is_inside_tree()
	save_config()
	
	if !file_system_hsplit.is_inside_tree(): return
	
	remove_control_from_bottom_panel(file_system)
	file_system_dock.add_child(file_system)
	file_system_split.replace_by(file_system_vsplit, true)
	file_system_split_view.pressed = false


func _split_view_toggled(value: bool) -> void:
	yield(get_tree(), "idle_frame")
	if value != file_system_hsplit.is_inside_tree():
		_switch_file_system_dock()


func _switch_file_system_dock(value: int = SWITCH) -> void:
	if _switching: return
	
	if value != SWITCH:
		if file_system_hsplit.is_inside_tree():
			tool_button.pressed = !tool_button.pressed 
		return
	
	_switching = true
	
	if !file_system_hsplit.is_inside_tree():
		file_system_dock = file_system.get_parent()
		remove_control_from_docks(file_system)
		tool_button = add_control_to_bottom_panel(file_system, TITLE)
		tool_button.get_parent().move_child(tool_button, 0)
		tool_button.pressed = true
		
		split_container = file_system_hsplit
		file_system.rect_min_size = MIN_SIZE
	
	else:
		remove_control_from_bottom_panel(file_system)
		file_system_dock.add_child(file_system)
		file_system_dock.current_tab = file_system.get_index()
		
		split_container = file_system_vsplit
		file_system.rect_min_size = Vector2.ONE
	
	file_system_split.replace_by(split_container, true)
	file_system_split = split_container
	
	file_system_split_view.pressed = file_system_hsplit.is_inside_tree()
	
	_switching = false


func create_shortcut() -> void:
	## ------- CUSTOMIZE SHORTCUT ------- ##
	var shortcut_switch := InputEventKey.new()
	var shortcut_show := InputEventKey.new()
	var submenu_item := PopupMenu.new()
	
	shortcut_switch.alt = true
	shortcut_switch.scancode = KEY_S
	shortcut_show.control = true
	shortcut_show.scancode = KEY_SPACE
	
	submenu_item.add_item(
			TITLE_TOOL_MENU_SWITCH,
			SWITCH,
			shortcut_switch.get_scancode_with_modifiers()
	)
	submenu_item.add_item(
			TITLE_TOOL_MENU_SHOW,
			VISIBLE,
			shortcut_show.get_scancode_with_modifiers()
	)
	
	add_tool_submenu_item(TITLE, submenu_item)
	submenu_item.connect("index_pressed", self, "_switch_file_system_dock")


func load_config() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH_CONFIG) != OK:
		_switch_file_system_dock()
		return
	
	for item in config.keys():
		config[item] = cfg.get_value(TITLE, item, config.get(item))
	
	if config.docked:
		_switch_file_system_dock()


func save_config() -> void:
	var cfg := ConfigFile.new()
	for item in config.keys():
		cfg.set_value(TITLE, item, config.get(item))
	
	cfg.save(PATH_CONFIG)


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░ Title: ⋈NV File System
# ░░█▀█░█▀█░█░░░█░░░█░█░█▀▀░░ Act: bottom panel FileSystem
# ░░█░█░█▀█░░▀▄░░▀▄░▀▄▀░█▀▀░░ Cast[Editor⋈, FileSystem⋈]
# ░░▀░▀░▀░▀░░░▀░░░▀░░▀░░▀▀▀░░ Writters[@⋈illlustr]
# ░ Projects ░░░░░░░░░░░░░░░░ https://github.com/naiiveprojects
