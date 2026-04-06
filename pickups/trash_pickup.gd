extends Area2D

var _inside: Array[Player] = []


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	add_to_group(&"trash_pickup")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is Player and body not in _inside:
		_inside.append(body as Player)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_inside.erase(body as Player)


func _physics_process(_delta: float) -> void:
	var dead: Array[Player] = []
	for p in _inside:
		if not is_instance_valid(p):
			dead.append(p)
	for p in dead:
		_inside.erase(p)

	for p in _inside:
		if Input.is_action_just_pressed(&"drop_seed" + p.action_suffix):
			if p.try_pickup_trash():
				queue_free()
				return
