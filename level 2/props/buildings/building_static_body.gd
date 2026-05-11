extends StaticBody2D
## Roof strip only: `RectangleShape2D` covers the top quarter of the `Sprite2D` (full width, centered sprite).

const COLLISION_LAYER_BUILDING := 16
const _TOP_FRACTION := 0.25


func _ready() -> void:
	collision_mask = 0
	if not visible:
		collision_layer = 0
		return
	collision_layer = COLLISION_LAYER_BUILDING
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if sprite == null or sprite.texture == null or collision_shape == null:
		return
	var full := sprite.texture.get_size() * sprite.scale.abs()
	var strip_h := full.y * _TOP_FRACTION
	var rect := RectangleShape2D.new()
	rect.size = Vector2(full.x, strip_h)
	collision_shape.shape = rect
	# Sprite is centered on the body; place the collider on the top quarter band.
	collision_shape.position = Vector2(0.0, -full.y * 0.5 + strip_h * 0.5)
