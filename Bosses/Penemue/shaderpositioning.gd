extends Sprite2D

func _process(_delta: float) -> void:
	if material:
		material.set_shader_parameter("node_global_position", global_position)
	else:
		push_warning(name + " has no material assigned!")
