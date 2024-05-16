extends Node3D

var colliding: bool = false



func dragged(drag_marker):
	if not colliding:
		global_position.z = drag_marker.global_position.z
		global_position.x = drag_marker.global_position.x




func _on_drop_area_body_entered(body: Node3D) -> void:
	colliding = true
	var tween = create_tween()
	tween.tween_property(self, "global_position:z", -192.959, 0.5)
	await tween.finished
	colliding = false

