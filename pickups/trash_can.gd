extends Node2D

## How many successful deposits complete the task (matches number of Trash pickups in the level).
@export var pieces_required: int = 2

var _inside: Array[Player] = []
var _deposited: int = 0
var _cleared: bool = false

@onready var _drop: Area2D = $DropZone


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_drop.body_entered.connect(_on_body_entered)
	_drop.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is Player and body not in _inside:
		_inside.append(body as Player)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_inside.erase(body as Player)


func _physics_process(_delta: float) -> void:
	if _cleared or Engine.is_editor_hint():
		return
	var dead: Array[Player] = []
	for p in _inside:
		if not is_instance_valid(p):
			dead.append(p)
	for p in dead:
		_inside.erase(p)

	for p in _inside:
		if Input.is_action_just_pressed(&"drop_seed" + p.action_suffix):
			if p.deposit_trash():
				p.add_score(Player.POINTS_TRASH_DEPOSIT)
				var pop_pos := global_position + Vector2(0, -72)
				PointsPopup.spawn(p, pop_pos, Player.POINTS_TRASH_DEPOSIT)
				_deposited += 1
				if _deposited >= pieces_required:
					_finish_trash_collection()


func _finish_trash_collection() -> void:
	_cleared = true
	_drop.set_deferred(&"monitoring", false)
