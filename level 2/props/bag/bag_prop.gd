extends Area2D
## Press **`drop_seed*`** while overlapping Lawrence to play his **pickup** clip (`pickup.png`); the prop is removed when the clip ends (no carry overlay).

var _inside: Array[Node2D] = []


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group(&"player") and body not in _inside:
		_inside.append(body as Node2D)


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group(&"player"):
		_inside.erase(body as Node2D)


func _physics_process(_delta: float) -> void:
	var dead: Array[Node2D] = []
	for p in _inside:
		if not is_instance_valid(p):
			dead.append(p)
	for p in dead:
		_inside.erase(p)

	for p in _inside:
		if not p.has_method(&"try_start_bag_pickup"):
			continue
		var sfx := str(p.get(&"action_suffix"))
		if Input.is_action_just_pressed(&"drop_seed" + sfx):
			if bool(p.call(&"try_start_bag_pickup", self)):
				return
