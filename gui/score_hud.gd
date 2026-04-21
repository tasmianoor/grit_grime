extends CanvasLayer

const _GAME_THEME: Theme = preload("res://gui/theme.tres")
const _OUTLINE_PX := 2


func _ready() -> void:
	layer = 95
	var root := Control.new()
	root.theme = _GAME_THEME
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var players: Array[Node] = get_tree().get_nodes_in_group(&"player")
	players.sort_custom(func(a: Node, b: Node) -> bool: return a.name < b.name)

	if players.is_empty():
		return

	if players.size() == 1 and players[0] is Player:
		_add_single_player_hud(root, players[0] as Player)
	else:
		_add_multi_player_hud(root, players)


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
