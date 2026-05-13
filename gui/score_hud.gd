extends CanvasLayer

const _GAME_THEME: Theme = preload("res://gui/theme.tres")
const _OUTLINE_PX := 2
const _MISSION_HEADER_FONT := Color(0.96, 0.97, 1.0, 1.0)
const _MISSION_HEADER_FONT_HOT := Color(1.0, 1.0, 1.0, 1.0)
const _MEMPHIS_PANEL_TITLE := "A favor for Feena"
const _MEMPHIS_ALL_DONE_LINE := "[color=#FDBA21]Nice work! Now find Feena[/color]"
const _CHECKLIST_LINES: PackedStringArray = [
	"1. Reduce smog by planting trees",
	"2. Clean up the park and river",
	"3. Bring back the blue heron to the park",
]

const _L2_PANEL_TITLE := "Beale back to life"
const _L2_ALL_DONE_LINE := (
	"[color=#FDBA21]You brought Christie back to life! Now go to Bruno[/color]"
)
const _L2_CHECKLIST_LINES: PackedStringArray = [
	"1. Weatherize rooftops to beat the heat",
	"2. Change to energy efficient ACs",
	"3. Bring back monarch butterflies",
]


var _memphis_goals_script: GDScript
var _level2_goals_script: GDScript
## Current mission HUD copy (Memphis L1 vs Beale L2); set in **`_add_memphis_checklist`**.
var _mission_panel_title: String = ""
var _mission_all_done_line: String = ""
var _mission_checklist_lines: PackedStringArray = []

var _memphis_mission_expanded := true
var _memphis_outer: PanelContainer
var _memphis_row_rtl: Array[RichTextLabel] = []
var _memphis_congrats_rtl: RichTextLabel
var _memphis_done_prev: Array[bool] = [false, false, false]


func _ready() -> void:
	_memphis_goals_script = load("res://gui/memphis_mission_goals.gd") as GDScript
	_level2_goals_script = load("res://gui/level2_mission_goals.gd") as GDScript
	layer = 95
	var root := Control.new()
	root.theme = _GAME_THEME
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var gl := get_tree().get_first_node_in_group(&"game_level") as Node
	if _uses_memphis_mission_hud(gl):
		_add_memphis_checklist(root, gl)
		set_process(true)
		return

	var players: Array[Node] = get_tree().get_nodes_in_group(&"player")
	players.sort_custom(func(a: Node, b: Node) -> bool: return a.name < b.name)

	if players.is_empty():
		return

	var first := players[0]
	if first != null and first.has_signal(&"score_changed"):
		_add_single_player_hud(root, first)


func _memphis_header_visual_idle(header: Button) -> void:
	header.add_theme_color_override(&"font_color", _MISSION_HEADER_FONT)
	header.add_theme_color_override(&"font_hover_color", _MISSION_HEADER_FONT_HOT)
	header.add_theme_color_override(&"font_pressed_color", Color(0.88, 0.9, 1.0, 1.0))
	header.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 1))
	header.add_theme_constant_override(&"outline_size", _OUTLINE_PX)
	header.remove_theme_color_override(&"font_shadow_color")
	header.remove_theme_constant_override(&"shadow_offset_x")
	header.remove_theme_constant_override(&"shadow_offset_y")


func _memphis_header_visual_hot(header: Button) -> void:
	header.add_theme_color_override(&"font_color", Color(1.0, 1.0, 1.0, 1.0))
	header.add_theme_color_override(&"font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	header.add_theme_color_override(&"font_pressed_color", Color(0.88, 0.9, 1.0, 1.0))
	header.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 1))
	header.add_theme_constant_override(&"outline_size", _OUTLINE_PX)
	header.remove_theme_color_override(&"font_shadow_color")
	header.remove_theme_constant_override(&"shadow_offset_x")
	header.remove_theme_constant_override(&"shadow_offset_y")


func _memphis_header_refresh_hot_state(header: Button) -> void:
	if header.is_hovered() or header.has_focus():
		_memphis_header_visual_hot(header)
	else:
		_memphis_header_visual_idle(header)


func _memphis_schedule_fit_outer_height(outer: PanelContainer) -> void:
	call_deferred(&"_memphis_fit_outer_layout_deferred", outer)


func _memphis_apply_outer_rect(outer: PanelContainer) -> void:
	if not is_instance_valid(outer):
		return
	const right_margin := 12.0
	var sz := outer.get_combined_minimum_size()
	outer.offset_right = -right_margin
	outer.offset_left = outer.offset_right - sz.x
	var body_n := outer.find_child(&"MissionChecklist", true, false) as Control
	var floor_h := 100.0 if body_n != null and body_n.visible else 40.0
	outer.offset_bottom = outer.offset_top + maxf(sz.y, floor_h)


func _memphis_fit_outer_layout_deferred(outer: PanelContainer) -> void:
	await get_tree().process_frame
	_memphis_apply_outer_rect(outer)


func _process(_delta: float) -> void:
	if _memphis_row_rtl.is_empty():
		return
	_memphis_sync_mission_strikes()


func _memphis_row_bbcode(done: bool, line: String) -> String:
	if done:
		return "[s][color=#8ea0b0]%s[/color][/s]" % line
	return line


func _memphis_header_chevron(expanded: bool) -> String:
	return ("%s  ▼" if expanded else "%s  ▶") % _mission_panel_title


func _memphis_sync_mission_strikes() -> void:
	var gl := get_tree().get_first_node_in_group(&"game_level") as Node
	if gl == null:
		return
	var cur: Array[bool]
	if _level2_mission_hud_variant(gl) and _level2_goals_script != null:
		cur = [
			bool(_level2_goals_script.call(&"roofs_weatherized_complete", gl)),
			bool(_level2_goals_script.call(&"ac_upgrades_all_complete", get_tree())),
			bool(_level2_goals_script.call(&"monarch_butterflies_present", get_tree())),
		]
	else:
		cur = [
			bool(_memphis_goals_script.call(&"trees_goal_met", gl)),
			bool(_memphis_goals_script.call(&"trash_all_cleared", get_tree())),
			bool(_memphis_goals_script.call(&"heron_goal_met", get_tree())),
		]
	var show_congrats := cur[0] and cur[1] and cur[2]
	if _level2_mission_hud_variant(gl) and _level2_goals_script != null:
		show_congrats = bool(_level2_goals_script.call(&"christie_performance_complete", get_tree()))
	var strikes_changed := false
	for i in 3:
		if cur[i] != _memphis_done_prev[i]:
			strikes_changed = true
			break
	var layout_dirty := strikes_changed
	if strikes_changed:
		_memphis_done_prev = cur.duplicate()
		for i in 3:
			_memphis_row_rtl[i].text = _memphis_row_bbcode(cur[i], _mission_checklist_lines[i])
	if is_instance_valid(_memphis_congrats_rtl):
		if _memphis_congrats_rtl.visible != show_congrats:
			_memphis_congrats_rtl.visible = show_congrats
			layout_dirty = true
	if layout_dirty and is_instance_valid(_memphis_outer):
		_memphis_apply_outer_rect(_memphis_outer)
		_memphis_schedule_fit_outer_height(_memphis_outer)


func _uses_memphis_mission_hud(gl: Node) -> bool:
	if gl == null:
		return false
	if String(gl.get(&"level_display_name")) == String(_memphis_goals_script.call(&"display_name")):
		return true
	var opt: Variant = gl.get(&"use_memphis_mission_hud")
	return opt != null and bool(opt)


func _level2_mission_hud_variant(gl: Node) -> bool:
	if gl == null:
		return false
	if String(gl.get(&"level_display_name")) == String(_memphis_goals_script.call(&"display_name")):
		return false
	var opt: Variant = gl.get(&"use_memphis_mission_hud")
	return opt != null and bool(opt)


func _mission_hud_strings_for_game_level(gl: Node) -> void:
	var memphis_name := String(_memphis_goals_script.call(&"display_name"))
	if String(gl.get(&"level_display_name")) == memphis_name:
		_mission_panel_title = _MEMPHIS_PANEL_TITLE
		_mission_all_done_line = _MEMPHIS_ALL_DONE_LINE
		_mission_checklist_lines = _CHECKLIST_LINES
		return
	var opt: Variant = gl.get(&"use_memphis_mission_hud")
	if opt != null and bool(opt):
		_mission_panel_title = _L2_PANEL_TITLE
		_mission_all_done_line = _L2_ALL_DONE_LINE
		_mission_checklist_lines = _L2_CHECKLIST_LINES
		return
	_mission_panel_title = _MEMPHIS_PANEL_TITLE
	_mission_all_done_line = _MEMPHIS_ALL_DONE_LINE
	_mission_checklist_lines = _CHECKLIST_LINES


func _add_memphis_checklist(root: Control, gl: Node) -> void:
	_mission_hud_strings_for_game_level(gl)
	const mission_navy := Color("#002962")
	var panel_style := StyleBoxFlat.new()
	var bg_fill := mission_navy.darkened(0.68)
	bg_fill.a = 0.94
	panel_style.bg_color = bg_fill
	panel_style.border_color = mission_navy.darkened(0.38)
	panel_style.set_border_width_all(1)
	panel_style.corner_radius_top_left = 6
	panel_style.corner_radius_top_right = 6
	panel_style.corner_radius_bottom_right = 6
	panel_style.corner_radius_bottom_left = 6
	panel_style.content_margin_left = 10
	panel_style.content_margin_top = 8
	panel_style.content_margin_right = 10
	panel_style.content_margin_bottom = 10

	var outer := PanelContainer.new()
	_memphis_outer = outer
	outer.add_to_group(&"mission_hud_panel")
	outer.mouse_filter = Control.MOUSE_FILTER_STOP
	outer.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	outer.anchor_bottom = 0.0
	outer.offset_top = 8.0
	outer.offset_right = -12.0
	outer.offset_left = outer.offset_right
	outer.add_theme_stylebox_override(&"panel", panel_style)

	var inner := VBoxContainer.new()
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_theme_constant_override(&"separation", 6)
	outer.add_child(inner)

	var header := Button.new()
	header.name = &"MissionHeader"
	header.flat = true
	header.focus_mode = Control.FOCUS_ALL
	header.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	header.alignment = HORIZONTAL_ALIGNMENT_LEFT
	header.text = _memphis_header_chevron(_memphis_mission_expanded)
	header.add_theme_font_size_override(&"font_size", 15)
	_memphis_header_visual_idle(header)
	header.mouse_entered.connect(func() -> void: _memphis_header_visual_hot(header))
	header.mouse_exited.connect(func() -> void: _memphis_header_refresh_hot_state(header))
	header.focus_entered.connect(func() -> void: _memphis_header_visual_hot(header))
	header.focus_exited.connect(func() -> void: _memphis_header_visual_idle(header))
	inner.add_child(header)

	var body := VBoxContainer.new()
	body.name = &"MissionChecklist"
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.visible = _memphis_mission_expanded
	body.add_theme_constant_override(&"separation", 4)
	for line in _mission_checklist_lines:
		var row := RichTextLabel.new()
		row.bbcode_enabled = true
		row.fit_content = true
		row.scroll_active = false
		row.autowrap_mode = TextServer.AUTOWRAP_OFF
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_theme_font_size_override(&"normal_font_size", 13)
		row.add_theme_color_override(&"default_color", Color(0.94, 0.95, 0.98, 1.0))
		row.text = _memphis_row_bbcode(false, line)
		body.add_child(row)
		_memphis_row_rtl.append(row)

	var congrats := RichTextLabel.new()
	congrats.name = &"MemphisAllDoneLine"
	congrats.bbcode_enabled = true
	congrats.fit_content = true
	congrats.scroll_active = false
	congrats.autowrap_mode = TextServer.AUTOWRAP_OFF
	congrats.mouse_filter = Control.MOUSE_FILTER_IGNORE
	congrats.visible = false
	congrats.add_theme_font_size_override(&"normal_font_size", 14)
	congrats.text = _mission_all_done_line
	body.add_child(congrats)
	_memphis_congrats_rtl = congrats

	inner.add_child(body)

	header.pressed.connect(
		func() -> void:
			_memphis_mission_expanded = not _memphis_mission_expanded
			body.visible = _memphis_mission_expanded
			header.text = _memphis_header_chevron(_memphis_mission_expanded)
			_memphis_schedule_fit_outer_height(outer)
			_memphis_header_refresh_hot_state(header)
	)

	root.add_child(outer)
	_memphis_apply_outer_rect(outer)
	_memphis_schedule_fit_outer_height(outer)


func _add_single_player_hud(root: Control, player: Node) -> void:
	var lab := _make_label()
	_bind_player(player, lab)
	lab.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	lab.offset_left = -200.0
	lab.offset_top = 6.0
	lab.offset_right = -10.0
	lab.offset_bottom = 36.0
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	root.add_child(lab)


func _make_label() -> Label:
	var lab := Label.new()
	lab.add_theme_font_size_override(&"font_size", 16)
	lab.add_theme_color_override(&"font_color", Color(1, 1, 1, 1))
	lab.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 1))
	lab.add_theme_constant_override(&"outline_size", _OUTLINE_PX)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return lab


func _player_prefix(_p: Node) -> String:
	return "Points"


func _format_line(p: Node, value: int) -> String:
	return "%s: %d" % [_player_prefix(p), value]


func _bind_player(player: Node, lab: Label) -> void:
	if not player.has_signal(&"score_changed"):
		return
	lab.text = _format_line(player, int(player.get(&"score")))
	player.connect(
		&"score_changed",
		func(new_score: int) -> void:
			lab.text = _format_line(player, new_score)
	)
