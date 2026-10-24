extends Camera2D
class_name ReflectionCamera

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var main_camera: Camera2D = player.get_node("Camera2D")
	if main_camera == null:
		return

	var mirrored_y: float = player.global_position.y + (player.global_position.y - main_camera.global_position.y)
	global_position = Vector2(main_camera.global_position.x, mirrored_y)
	zoom = main_camera.zoom
	rotation = main_camera.rotation
