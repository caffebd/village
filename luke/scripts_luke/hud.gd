extends Control
@onready var target: TextureRect = %target
@onready var text_box: ColorRect = %TextBackground

@export var use_fade: bool = true

var target_mode = "off"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignals.show_speech.connect(_show_speech)
	GlobalSignals.hide_speech.connect(_hide_speech)
	GlobalSignals.start_game.connect(_start_game)
	%TextBackground.modulate.a = 0.0
	if use_fade:
		$Cover.modulate.a = 1.0
		$TopLid.position.y = 0.0
		$BottomLid.position.y = 540.0
		var tween = create_tween()
		tween.tween_property(%Title, "modulate:a", 1.0, 2.0)



func _start_game():
	_use_fade_in()

func _show_speech(text: String):
	%Speech.text = text
	var tween = create_tween()
	tween.tween_property(text_box, "modulate:a", 1.0, 2.0)
	

func _hide_speech():
	var tween = create_tween()
	tween.tween_property(text_box, "modulate:a", 0.0, 1.0)

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
