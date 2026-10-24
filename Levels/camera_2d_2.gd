extends Camera2D

@export var target: CharacterBody2D
@export var deadzone := Vector2(128, 96)
@export var follow_speed := 6.0

func _process(delta):
	if target == null:
		return

	var desired := global_position

	if target.global_position.x < global_position.x - deadzone.x:
		desired.x = target.global_position.x + deadzone.x

	elif target.global_position.x > global_position.x + deadzone.x:
		desired.x = target.global_position.x - deadzone.x

	if target.global_position.y < global_position.y - deadzone.y:
		desired.y = target.global_position.y + deadzone.y

	elif target.global_position.y > global_position.y + deadzone.y:
		desired.y = target.global_position.y - deadzone.y

	global_position = global_position.lerp(desired, delta * follow_speed)
