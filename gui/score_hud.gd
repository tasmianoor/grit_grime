extends CanvasLayer

const _GAME_THEME: Theme = preload("res://gui/theme.tres")
const _OUTLINE_PX := 2
const _MEMPHIS_L1_NAME := "Memphis Riverfront"
const _CHECKLIST_LINES: PackedStringArray = [
	"1. Reduce smog by planting trees",
	"2. Clean up the park and river",
	"3. Bring back the blue heron to the park",
]

var _memphis_mission_expanded := true


func _ready() -> void:
	layer = 95
	var root := Control.new()
	root.theme = _GAME_THEME
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	if _is_memphis_level_one():
		_add_memphis_checklist(root)
		return

	var players: Array[Node] = get_tree().get_nodes_in_group(&"player")
	players.sort_custom(func(a: Node, b: Node) -> bool: return a.name < b.name)

	if players.is_empty():
		return

	if players.size() == 1 and players[0] is Player:
		_add_single_player_hud(root, players[0] as Player)
	else:
		_add_multi_player_hud(root, players)


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


func _is_memphis_level_one() -> bool:
	var gl := get_tree().get_first_node_in_group(&"game_level")
	if gl == null:
		return false
	return String(gl.get(&"level_display_name")) == _MEMPHIS_L1_NAME


func _add_memphis_checklist(root: Control) -> void:
	const mission_navy := Color("#00235E")
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
	header.focus_mode = Control.FOCUS_NONE
	header.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	header.alignment = HORIZONTAL_ALIGNMENT_LEFT
	header.text = "Mission  ▼" if _memphis_mission_expanded else "Mission  ▶"
	header.add_theme_font_size_override(&"font_size", 15)
	header.add_theme_color_override(&"font_color", Color(0.96, 0.97, 1.0, 1.0))
	header.add_theme_color_override(&"font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	header.add_theme_color_override(&"font_pressed_color", Color(0.88, 0.9, 1.0, 1.0))
	header.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 1))
	header.add_theme_constant_override(&"outline_size", _OUTLINE_PX)
	inner.add_child(header)

	var body := VBoxContainer.new()
	body.name = &"MissionChecklist"
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.visible = _memphis_mission_expanded
	body.add_theme_constant_override(&"separation", 4)
	for line in _CHECKLIST_LINES:
		var row := Label.new()
		row.text = line
		row.autowrap_mode = TextServer.AUTOWRAP_OFF
		row.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.add_theme_font_size_override(&"font_size", 13)
		row.add_theme_color_override(&"font_color", Color(0.94, 0.95, 0.98, 1.0))
		row.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 1))
		row.add_theme_constant_override(&"outline_size", _OUTLINE_PX)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		body.add_child(row)
	inner.add_child(body)

	header.pressed.connect(
		func() -> void:
			_memphis_mission_expanded = not _memphis_mission_expanded
			body.visible = _memphis_mission_expanded
			header.text = "Mission  ▼" if _memphis_mission_expanded else "Mission  ▶"
			_memphis_schedule_fit_outer_height(outer)
	)

	root.add_child(outer)
	_memphis_apply_outer_rect(outer)
	_memphis_schedule_fit_outer_height(outer)


func _add_single_player_hud(root: Control, player: Player) -> void:
	var lab := _make_label()
	_bind_player(player, lab)
	lab.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	lab.offset_left = -200.0
	lab.offset_top = 6.0
	lab.offset_right = -10.0
	lab.offset_bottom = 36.0
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	root.add_child(lab)


func _add_multi_player_hud(root: Control, players: Array[Node]) -> void:
	var left_done := false
	for n in players:
		if not n is Player:
			continue
		var p := n as Player
		var lab := _make_label()
		_bind_player(p, lab)
		if not left_done:
			lab.set_anchors_preset(Control.PRESET_TOP_LEFT)
			lab.offset_left = 10.0
			lab.offset_top = 6.0
			lab.offset_right = 200.0
			lab.offset_bottom = 36.0
			left_done = true
		else:
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


func _player_prefix(p: Player) -> String:
	match String(p.action_suffix):
		"_p1":
			return "P1"
		"_p2":
			return "P2"
		_:
			return "Points"


func _format_line(p: Player, value: int) -> String:
	return "%s: %d" % [_player_prefix(p), value]


func _bind_player(player: Player, lab: Label) -> void:
	lab.text = _format_line(player, player.score)
	player.score_changed.connect(func(new_score: int) -> void:
		lab.text = _format_line(player, new_score)
	)
