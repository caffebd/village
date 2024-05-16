extends Node3D

#comment for push

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#GlobalSignals.emit_signal("start_clearing")
	#var tween = create_tween().parallel()
	#tween.tween_property($WorldEnvironment, "environment:sky:sky_material:sky_top_color", Color("327085"), 2.0)
	#tween.tween_property($WorldEnvironment, "environment:sky:sky_material:sky_horizon_color", Color("000000"), 2.0)
	#tween.tween_property($WorldEnvironment, "environment:sky:sky_material:ground_horizon_color", Color("000000"), 2.0)
	#tween.tween_property($WorldEnvironment, "environment:volumetric_fog_albedo", Color("3c3c3c"), 2.0)
	#tween.tween_property($WorldEnvironment, "environment:volumetric_fog_emission", Color("0f2722"), 2.0)
	#tween.tween_property($WorldEnvironment, "environment:volumetric_fog_density", 0.05, 2.0)
	#tween.tween_property($sun, "light_energy", 0.0, 2.0)
	#tween.tween_property($moon, "light_energy", 0.08, 2.0)
	#%WorldEnvironment.environment.sky.sky_material.sky_top_color = Color("a1a95a")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
