extends Node2D

## Extra reach beyond the `DropZone` shape (world px), so deposits work when standing at the rim of the can art.
const _DEPOSIT_PROXIMITY_PX := 120.0

var _inside: Array[Player] = []

@onready var _drop: Area2D = $DropZone
@onready var _hit: CollisionShape2D = $DropZone/CollisionShape2D


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


func _deposit_anchor() -> Vector2:
	return _hit.global_position if _hit != null else global_position


func _player_within_deposit_proximity(p: Player) -> bool:
	return _deposit_anchor().distance_to(p.global_position) <= _DEPOSIT_PROXIMITY_PX


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var dead: Array[Player] = []
	for p in _inside:
		if not is_instance_valid(p):
			dead.append(p)
	for p in dead:
		_inside.erase(p)

	var to_poll: Array[Player] = []
	var seen: Dictionary = {}
	for p in _inside:
		if is_instance_valid(p):
			to_poll.append(p)
			seen[p] = true
	var tree := get_tree()
	if tree != null:
		for n in tree.get_nodes_in_group(&"player"):
			if not n is Player:
				continue
			var pl := n as Player
			if not is_instance_valid(pl) or not pl.is_holding_trash():
				continue
			if seen.has(pl):
				continue
			if _player_within_deposit_proximity(pl):
				to_poll.append(pl)
				seen[pl] = true

	for p in to_poll:
		if Input.is_action_just_pressed(&"drop_seed" + p.action_suffix):
			if p.deposit_trash():
				p.add_score(Player.POINTS_TRASH_DEPOSIT)
				var pop_pos := global_position + Vector2(0, -72)
				PointsPopup.spawn(p, pop_pos, Player.POINTS_TRASH_DEPOSIT)
