extends Node2D
## Hold **drop_seed** (+ `action_suffix`) in range to fill the wheel; release resets. At 100%, swap to **new** AC animation.

@export var flip_old_sprite := false
@export var hold_duration_sec := 2.25

@onready var _old_sprite: Sprite2D = $OldSprite
@onready var _new_sprite: Sprite2D = $NewSprite
@onready var _area: Area2D = $InteractArea
@onready var _wheel: AcOldLoadWheel = $LoadWheel as AcOldLoadWheel

var _progress := 0.0
var _completed := false


func _ready() -> void:
	add_to_group(&"ac_old_unit")
	_old_sprite.flip_h = flip_old_sprite
	_new_sprite.flip_h = flip_old_sprite
	_area.collision_layer = 0
	_area.collision_mask = 1
	_area.monitoring = true
	_wheel.visible = false
	_wheel.set_progress_ratio(0.0)


func _physics_process(delta: float) -> void:
	if _completed:
		return
	var in_range := false
	var any_hold := false
	for body in _area.get_overlapping_bodies():
		if not body.is_in_group(&"player"):
			continue
		if body.has_method(&"is_holding_trash") and bool(body.call(&"is_holding_trash")):
			continue
		in_range = true
		var sfx := str(body.get(&"action_suffix"))
		if Input.is_action_pressed(&"drop_seed" + sfx):
			any_hold = true
	if not in_range:
		_reset_hold_visual()
		return
	if any_hold:
		_progress += delta / maxf(0.05, hold_duration_sec)
		_wheel.visible = true
		_wheel.set_progress_ratio(_progress)
		if _progress >= 1.0:
			_complete_swap()
	else:
		_reset_hold_visual()


func _reset_hold_visual() -> void:
	_progress = 0.0
	_wheel.visible = false
	_wheel.set_progress_ratio(0.0)


func is_ac_upgrade_complete() -> bool:
	return _completed


func _complete_swap() -> void:
	_completed = true
	_reset_hold_visual()
	_old_sprite.visible = false
	_new_sprite.visible = true
	set_physics_process(false)
	_area.monitoring = false
