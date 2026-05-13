extends Node2D
## Hold **drop_seed** (+ `action_suffix`) in range to fill the wheel; release resets. At 100%, swap to **new** AC animation.
## Requires Lawrence's post-bag outfit (`Lawrence/bag_*`); otherwise shows a blocked hint (same typography as soil patch hint in Level 1).

const _GAME_THEME: Theme = preload("res://gui/theme.tres")
const _BLOCKED_HINT_TEXT := "Special tools needed to replace old unit"
const _LABEL_OUTLINE_PX := 3

@export var flip_old_sprite := false
@export var hold_duration_sec := 2.25
@export var blocked_hint_world_offset := Vector2(0, -55)

@onready var _old_sprite: Sprite2D = $OldSprite
@onready var _new_sprite: Sprite2D = $NewSprite
@onready var _area: Area2D = $InteractArea
@onready var _interact_shape: CollisionShape2D = $InteractArea/CollisionShape2D
@onready var _wheel: AcOldLoadWheel = $LoadWheel as AcOldLoadWheel

var _progress := 0.0
var _completed := false
var _hint_layer: CanvasLayer
var _hint_label: Label


func _ready() -> void:
	add_to_group(&"ac_old_unit")
	_old_sprite.flip_h = flip_old_sprite
	_new_sprite.flip_h = flip_old_sprite
	_area.collision_layer = 0
	_area.collision_mask = 1
	_area.monitoring = true
	_wheel.visible = false
	_wheel.set_progress_ratio(0.0)
	if not Engine.is_editor_hint():
		_setup_blocked_hint()


func _setup_blocked_hint() -> void:
	_hint_layer = CanvasLayer.new()
	_hint_layer.layer = 58
	add_child(_hint_layer)
	_hint_label = Label.new()
	_hint_label.name = &"AcBlockedToolsHint"
	_hint_label.text = _BLOCKED_HINT_TEXT
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.custom_minimum_size = Vector2(300, 0)
	_hint_label.add_theme_font_override(&"font", _GAME_THEME.default_font)
	_hint_label.add_theme_font_size_override(&"font_size", 13)
	_hint_label.add_theme_color_override(&"font_color", Color(1, 1, 1, 1))
	_hint_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 1))
	_hint_label.add_theme_constant_override(&"outline_size", _LABEL_OUTLINE_PX)
	_hint_label.visible = false
	_hint_layer.add_child(_hint_label)


func _set_blocked_hint_visible(on: bool, world_anchor: Vector2 = Vector2.ZERO) -> void:
	if _hint_label == null:
		return
	_hint_label.visible = on
	if not on:
		return
	var viewport := get_viewport()
	if viewport == null:
		return
	var screen_pos: Vector2 = viewport.get_canvas_transform() * world_anchor
	_hint_label.reset_size()
	_hint_label.position = screen_pos - _hint_label.size * 0.5


func _physics_process(delta: float) -> void:
	if _completed:
		return
	var in_range := false
	var blocked_holder := false
	var bag_holder := false
	for body in _area.get_overlapping_bodies():
		if not body.is_in_group(&"player"):
			continue
		if body.has_method(&"is_holding_trash") and bool(body.call(&"is_holding_trash")):
			continue
		in_range = true
		var sfx := str(body.get(&"action_suffix"))
		if not Input.is_action_pressed(&"drop_seed" + sfx):
			continue
		var has_bag := body.has_method(&"has_lawrence_bag_outfit_active") and bool(
			body.call(&"has_lawrence_bag_outfit_active")
		)
		if has_bag:
			bag_holder = true
		else:
			blocked_holder = true

	if not in_range:
		_reset_hold_visual()
		_set_blocked_hint_visible(false)
		return

	if blocked_holder and not bag_holder:
		_reset_hold_visual()
		_set_blocked_hint_visible(true, _interact_shape.global_position + blocked_hint_world_offset)
		return

	if bag_holder:
		_set_blocked_hint_visible(false)
		_progress += delta / maxf(0.05, hold_duration_sec)
		_wheel.visible = true
		_wheel.set_progress_ratio(_progress)
		if _progress >= 1.0:
			_complete_swap()
	else:
		_reset_hold_visual()
		_set_blocked_hint_visible(false)


func _reset_hold_visual() -> void:
	_progress = 0.0
	_wheel.visible = false
	_wheel.set_progress_ratio(0.0)


func is_ac_upgrade_complete() -> bool:
	return _completed


func _complete_swap() -> void:
	_completed = true
	_reset_hold_visual()
	_set_blocked_hint_visible(false)
	_old_sprite.visible = false
	_new_sprite.visible = true
	set_physics_process(false)
	_area.monitoring = false
