extends Node2D
## Spawns up to two sparrows once the first soil tree reaches locked maturity.

const _ACTOR_SCRIPT: GDScript = preload("res://level/props/birds/Sparrow/sparrow_actor.gd")

var _activated := false


func _ready() -> void:
	add_to_group(&"sparrows_ambient")


func notify_one_tree_matured() -> void:
	if Engine.is_editor_hint() or _activated:
		return
	_activated = true
	for i in 2:
		var bird := Node2D.new()
		bird.name = &"SparrowActor_%d" % i
		bird.set_script(_ACTOR_SCRIPT)
		add_child(bird)
		bird.call_deferred(&"begin_flight", float(i) * 0.55)
