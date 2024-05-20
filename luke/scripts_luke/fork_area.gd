extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		set_deferred("monitoring", false)
		Narration.main_index = Narration.fork_index
		Narration.sub_index = 0
		Narration.narrate()
		await get_tree().create_timer(4.0).timeout
		GlobalSignals.emit_signal("dad_call", 5)
		await get_tree().create_timer(4.0).timeout
		Narration.narrate()
