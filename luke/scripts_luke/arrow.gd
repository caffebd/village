extends Node3D

var stick_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignals.stick_drop.connect(_stick_drop)

func _stick_drop():
	stick_count += 1
	for i in stick_count:
		get_child(i).visible = true
	var needed = 3 - stick_count
	if needed > 0:
		GlobalSignals.emit_signal("show_speech", "Great. Now find another "+str(needed))
	else:
		GlobalSignals.emit_signal("show_speech", "Look, we can use this arrow to see which way we went.")
		await get_tree().create_timer(5).timeout
		GlobalSignals.emit_signal("hide_speech")
		GlobalSignals.emit_signal("show_narration", "Dad always liked to teach me something when we went walking.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
