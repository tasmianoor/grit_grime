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
@onready var _take_action_intro := center_cont.get_node(
	^"VBoxContainer/TakeActionSection/TakeActionIntro"
) as Label
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


## AC art shares **`new_ac1.png`** with an in-world **`AnimatedTexture`** loop; force a static raster for this UI icon.
func _static_cleanup_icon_texture(tex: Texture2D) -> Texture2D:
	if tex == null:
		return null
	var source := tex
	if tex is AnimatedTexture:
		var at := tex as AnimatedTexture
		var ft := at.get_frame_texture(0)
		if ft != null:
			source = ft
	var img: Image = source.get_image()
	if img == null:
		return source
	return ImageTexture.create_from_image(img)


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
	_icon_cleanup.texture = _static_cleanup_icon_texture(_icon_cleanup.texture)
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
	if level_index == 2:
		level_heading_label.text = "Level 2: Beale Street"
		_take_action_intro.text = _TAKE_ACTION_INTRO_LEVEL2
		_take_action_plant.text = _bbcode_level2_first_column()
	else:
		level_heading_label.text = "Level %d: %s" % [level_index, level_display_name]
		_take_action_intro.text = _TAKE_ACTION_INTRO_LEVEL1
		_take_action_plant.text = _bbcode_plant_column()
	complete_line_label.text = "Level Completed!"
	_apply_star_row(stars_filled)
	_star_feedback_label.text = star_feedback
	_star_feedback_label.visible = not star_feedback.is_empty()
	_take_action_section.visible = true
	_apply_take_action_icon_min_sizes()
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

const _TAKE_ACTION_INTRO_LEVEL1 := (
	"You restored the riverbank in the game. Here is how you can help in real life:"
)
const _TAKE_ACTION_INTRO_LEVEL2 := (
	"You fixed up Beale Street in the game. Here is how you can help in real life:"
)


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


## Level 2 completion: first column replaces riverbank “plant” copy (Beale / façade AC theme).
static func _bbcode_level2_first_column() -> String:
	var c := _LINK_HEX
	return _wrap_take_action_column(
		"Weatherize and cool your roof.\n"
		+ "Apply reflective coating to reduce heat. MLGW offers free energy audits and rebates.\n"
		+ "[color=%s][url=https://www.mlgw.com/residential/summertips]mlgw.com/residential[/url][/color] — efficiency programs for Memphis homes." % c
	)


static func _bbcode_cleanup_column() -> String:
	var c := _LINK_HEX
	return _wrap_take_action_column(
		"Upgrade your cooling.\n"
		+ "Replace old AC units with ENERGY STAR models. TVA EnergyRight offers rebates up to $300.\n"
		+ "[color=%s][url=https://energyright.com]energyright.com[/url][/color]" % c
	)


static func _bbcode_fish_column() -> String:
	var c := _LINK_HEX
	return _wrap_take_action_column(
		"Create a monarch waystation.\n"
		+ "Plant milkweed and native flowers. Memphis Botanic Garden sells native plants and offers resources.\n"
		+ "[color=%s][url=https://memphisbotanicgarden.com]memphisbotanicgarden.com[/url][/color]" % c
	)


static func _bbcode_bird_column() -> String:
	var c := _LINK_HEX
	return _wrap_take_action_column(
		"Sponsor a shade tree.\n"
		+ "Memphis City Beautiful plants trees to cool Memphis streets. Sponsor one today.\n"
		+ "[color=%s][url=https://memphiscitybeautiful.org]memphiscitybeautiful.org[/url][/color]" % c
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
