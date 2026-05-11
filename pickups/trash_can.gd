extends Node2D

## Extra reach beyond the `DropZone` shape (world px), so deposits work when standing at the rim of the can art.
const _DEPOSIT_PROXIMITY_PX := 120.0
## Match `player/player.gd` (avoid global `Player` at parse time).
const _POINTS_TRASH_DEPOSIT := 5

var _inside: Array[Node2D] = []

@onready var _drop: Area2D = $DropZone
@onready var _hit: CollisionShape2D = $DropZone/CollisionShape2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_drop.body_entered.connect(_on_body_entered)
	_drop.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group(&"player") and body not in _inside:
		_inside.append(body as Node2D)


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group(&"player"):
		_inside.erase(body as Node2D)


func _deposit_anchor() -> Vector2:
	return _hit.global_position if _hit != null else global_position


func _player_within_deposit_proximity(p: Node2D) -> bool:
	return _deposit_anchor().distance_to(p.global_position) <= _DEPOSIT_PROXIMITY_PX


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var dead: Array[Node2D] = []
	for p in _inside:
		if not is_instance_valid(p):
			dead.append(p)
	for p in dead:
		_inside.erase(p)

	var to_poll: Array[Node2D] = []
	var seen: Dictionary = {}
	for p in _inside:
		if is_instance_valid(p):
			to_poll.append(p)
			seen[p] = true
	var tree := get_tree()
	if tree != null:
		for n in tree.get_nodes_in_group(&"player"):
			if not n is Node2D:
				continue
			var pl := n as Node2D
			if not is_instance_valid(pl) or not pl.has_method(&"is_holding_trash"):
				continue
			if not bool(pl.call(&"is_holding_trash")):
				continue
			if seen.has(pl):
				continue
			if _player_within_deposit_proximity(pl):
				to_poll.append(pl)
				seen[pl] = true

	for p in to_poll:
		var sfx := str(p.get(&"action_suffix"))
		if Input.is_action_just_pressed(&"drop_seed" + sfx):
			if not p.has_method(&"deposit_trash"):
				continue
			if bool(p.call(&"deposit_trash")):
				if p.has_method(&"add_score"):
					p.call(&"add_score", _POINTS_TRASH_DEPOSIT)
				var pop_pos := global_position + Vector2(0, -72)
				PointsPopup.spawn(p, pop_pos, _POINTS_TRASH_DEPOSIT)
