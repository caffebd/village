extends Control
@onready var target: TextureRect = %target

@export var use_fade: bool = true

var target_mode = "off"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if use_fade:
		$Cover.modulate.a = 1.0
		$TopLid.position.y = 0.0
		$BottomLid.position.y = 540.0
		await get_tree().create_timer(5.0)
		_use_fade_in()


func _use_fade_in():
	var tween = create_tween()
	tween.tween_property($Cover, "modulate:a", 0.0, 3.0)
	await tween.finished
	%CloseEyes.play("open")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	%FPS.text = "FPS " + str(Engine.get_frames_per_second())

func set_target_mode(mode:String):
	if mode == target_mode:
		return
	target_mode = mode
	if target_mode=="off":
		target.modulate.a = 145.0
	elif target_mode == "interact":
		target.modulate.a = 255.0
