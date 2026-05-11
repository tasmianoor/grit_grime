class_name LevelCompleteScreen extends Control

const _LEVEL_SELECT_MAP := "res://map/map.tscn"
## Light blue for inline URLs (opens in default browser via `meta_clicked`).
const _LINK_HEX := "#7ec8ff"
const _STAR_FILLED := Color(0.992157, 0.729412, 0.129412, 1)
const _STAR_EMPTY := Color(0.2, 0.22, 0.26, 1)

@export var fade_in_duration := 0.3
@export var fade_out_duration := 0.2

@onready var center_cont := $ColorRect/CenterContainer as CenterContainer
@onready var retry_button := center_cont.get_node(^"VBoxContainer/PrimaryActionsRow/RetryButton") as Button
@onready var continue_button := center_cont.get_node(
	^"VBoxContainer/PrimaryActionsRow/NextLevelButton"
) as Button
@onready var level_heading_label := center_cont.get_node(^"VBoxContainer/LevelHeadingLabel") as Label
@onready var complete_line_label := center_cont.get_node(^"VBoxContainer/CompleteLineLabel") as Label
@onready var _star_row := center_cont.get_node(^"VBoxContainer/StarsRow") as HBoxContainer
@onready var _star_feedback_label := center_cont.get_node(^"VBoxContainer/StarFeedbackLabel") as Label
@onready var _take_action_section := center_cont.get_node(^"VBoxContainer/TakeActionSection") as VBoxContainer
@onready var _take_action_plant := center_cont.get_node(
	^"VBoxContainer/TakeActionSection/TakeActionResourcesRow/ColumnPlant/TakeActionPlant"
) as RichTextLabel
@onready var _take_action_cleanup := center_cont.get_node(
	^"VBoxContainer/TakeActionSection/TakeActionResourcesRow/ColumnCleanup/TakeActionCleanup"
) as RichTextLabel
@onready var _take_action_fish := center_cont.get_node(
	^"VBoxContainer/TakeActionSection/TakeActionResourcesRow/ColumnFish/TakeActionFish"
) as RichTextLabel
@onready var _take_action_bird := center_cont.get_node(
	^"VBoxContainer/TakeActionSection/TakeActionResourcesRow/ColumnBird/TakeActionBird"
) as RichTextLabel
@onready var _icon_plant := center_cont.get_node(
	^"VBoxContainer/TakeActionSection/TakeActionResourcesRow/ColumnPlant/IconRowPlant/IconPlant"
) as TextureRect
@onready var _icon_cleanup := center_cont.get_node(
	^"VBoxContainer/TakeActionSection/TakeActionResourcesRow/ColumnCleanup/IconRowCleanup/IconCleanup"
) as TextureRect
@onready var _icon_fish := center_cont.get_node(
	^"VBoxContainer/TakeActionSection/TakeActionResourcesRow/ColumnFish/IconRowFish/IconFish"
) as TextureRect
@onready var _icon_bird := center_cont.get_node(
	^"VBoxContainer/TakeActionSection/TakeActionResourcesRow/ColumnBird/IconRowBird/IconBird"
) as TextureRect

var _blocking := false
var _star_labels: Array[Label] = []


func _ready() -> void:
	for c in _star_row.get_children():
		if c is Label:
			_star_labels.append(c as Label)
	for rtl: RichTextLabel in [
		_take_action_plant,
		_take_action_cleanup,
		_take_action_fish,
		_take_action_bird,
	]:
		if not rtl.meta_clicked.is_connected(_on_take_action_meta_clicked):
			rtl.meta_clicked.connect(_on_take_action_meta_clicked)
	_apply_take_action_icon_min_sizes()
	hide()


## `expand_mode = EXPAND_FIT_HEIGHT_PROPORTIONAL` with min width 0 can collapse to 0px in an `HBoxContainer`.
func _apply_take_action_icon_min_sizes() -> void:
	const icon_h := 52.0
	for icon: TextureRect in [_icon_plant, _icon_cleanup, _icon_fish, _icon_bird]:
		var tex := icon.texture
		var w := icon_h
		if tex != null:
			var th := float(tex.get_height())
			if th > 0.0:
				w = maxf(1.0, roundf(float(tex.get_width()) * icon_h / th))
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		icon.custom_minimum_size = Vector2(w, icon_h)


func is_blocking() -> bool:
	return _blocking


func present(
	level_index: int,
	level_display_name: String,
	stars_filled: int = 0,
	star_feedback: String = ""
) -> void:
	_blocking = true
	level_heading_label.text = "Level %d: %s" % [level_index, level_display_name]
	complete_line_label.text = "Level Completed!"
	_apply_star_row(stars_filled)
	_star_feedback_label.text = star_feedback
	_star_feedback_label.visible = not star_feedback.is_empty()
	_take_action_section.visible = true
	_apply_take_action_icon_min_sizes()
	_take_action_plant.text = _bbcode_plant_column()
	_take_action_cleanup.text = _bbcode_cleanup_column()
	_take_action_fish.text = _bbcode_fish_column()
	_take_action_bird.text = _bbcode_bird_column()
	var show_next_level := stars_filled >= 2
	continue_button.visible = show_next_level
	show()
	if show_next_level:
		continue_button.grab_focus()
	else:
		retry_button.grab_focus()

	modulate.a = 0.0
	center_cont.anchor_bottom = 0.5
	var tween := create_tween()
	tween.tween_property(
		self,
		^"modulate:a",
		1.0,
		fade_in_duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(
		center_cont,
		^"anchor_bottom",
		1.0,
		fade_out_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## Matches `TakeAction*` `theme_override_font_sizes/normal_font_size` in `level_complete_screen.tscn`.
const _TAKE_ACTION_COLUMN_FONT_PX := 12


static func _wrap_take_action_column(inner: String) -> String:
	var sz := _TAKE_ACTION_COLUMN_FONT_PX
	return "[font_size=%d]%s[/font_size]" % [sz, inner]


static func _bbcode_plant_column() -> String:
	var c := _LINK_HEX
	return _wrap_take_action_column(
		"Plant native species.\n"
		+ "Volunteer with Wolf River Conservancy to plant willows and switchgrass along real riverbanks.\n"
		+ "[color=%s][url=https://wolfriver.org]wolfriver.org[/url][/color]" % c
	)


static func _bbcode_cleanup_column() -> String:
	var c := _LINK_HEX
	return _wrap_take_action_column(
		"Join a river cleanup.\n"
		+ "Memphis River Parks organizes volunteer events along the Mississippi. Bring gloves and a friend.\n"
		+ "[color=%s][url=https://memphisriverparks.org]memphisriverparks.org[/url][/color]" % c
	)


static func _bbcode_fish_column() -> String:
	return _wrap_take_action_column(
		"Protect aquatic life.\n"
		+ "Practice catch-and-release fishing. Report illegal dumping to TDEC: 1-888-891-8332"
	)


static func _bbcode_bird_column() -> String:
	var c := _LINK_HEX
	return _wrap_take_action_column(
		"Create backyard habitat.\n"
		+ "Plant milkweed and coneflowers. Install a nesting box for warblers.\n"
		+ "[color=%s][url=https://memphisbotanicgarden.com]memphisbotanicgarden.com[/url][/color]" % c
	)


func _on_take_action_meta_clicked(meta: Variant) -> void:
	if typeof(meta) != TYPE_STRING:
		return
	var s := str(meta)
	if s.is_empty():
		return
	OS.shell_open(s)


func _apply_star_row(filled_count: int) -> void:
	var n := clampi(filled_count, 0, _star_labels.size())
	for i in range(_star_labels.size()):
		var lab := _star_labels[i]
		var col := _STAR_FILLED if i < n else _STAR_EMPTY
		lab.add_theme_color_override(&"font_color", col)


func _dismiss_immediate() -> void:
	get_tree().paused = false
	_blocking = false
	modulate.a = 1.0
	center_cont.anchor_bottom = 1.0
	hide()


func _on_retry_button_pressed() -> void:
	if not _blocking:
		return
	_dismiss_immediate()
	get_tree().reload_current_scene()


func _on_continue_button_pressed() -> void:
	if not _blocking:
		return
	var game := get_tree().get_first_node_in_group(&"game_controller")
	var next_path := ""
	if game != null and game.has_method(&"get_continue_scene_path"):
		next_path = str(game.get_continue_scene_path())
	if next_path.is_empty():
		next_path = _LEVEL_SELECT_MAP
	_dismiss_immediate()
	get_tree().change_scene_to_file(next_path)


func _on_back_to_map_button_pressed() -> void:
	if not _blocking:
		return
	_dismiss_immediate()
	get_tree().change_scene_to_file(_LEVEL_SELECT_MAP)
