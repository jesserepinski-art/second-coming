extends Sprite2D
class_name Ripple

@export var duration := 0.7

func _ready() -> void:
	var material := (self.material as ShaderMaterial)
	var tween := create_tween()
	tween.tween_method(_set_progress.bind(material), 0.0, 1.0, duration)
	tween.tween_callback(queue_free)

func _set_progress(value: float, material: ShaderMaterial) -> void:
	material.set_shader_parameter("progress", value)
