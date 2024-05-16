extends Node3D

var stick_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignals.stick_drop.connect(_stick_drop)

func _stick_drop():
	stick_count += 1
	for i in stick_count:
		get_child(i).visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
