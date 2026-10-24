extends CharacterBody2D
@export var talk_sound: AudioStream
@export var dialogue: DialogueData
@export var walk_speed := 80.0
@export var patrol_path: Node2D
@export var patrol_wait_time := 1.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var patrol_points: Array[Marker2D] = []
var patrol_index := 0
var waiting := false
var busy := false

func _ready():

	if patrol_path:
		for child in patrol_path.get_children():
			if child is Marker2D:
				patrol_points.append(child)

func interact():
	if busy:
		return

	if dialogue == null:
		return

	busy = true

	await Globals.textbox.start(dialogue.speaker_name, dialogue.lines, dialogue.portrait, talk_sound)
	await Globals.textbox.finished

	while Input.is_action_pressed("interact"):
		await get_tree().process_frame

	busy = false
func _physics_process(delta):

	if busy:
		velocity = Vector2.ZERO
		sprite.stop()
		move_and_slide()
		return

	if waiting:
		velocity = Vector2.ZERO
		sprite.stop()
		move_and_slide()
		return

	if patrol_points.is_empty():
		velocity = Vector2.ZERO
		sprite.stop()
		move_and_slide()
		return

	var target = patrol_points[patrol_index].global_position
	var direction = global_position.direction_to(target)

	velocity = direction * walk_speed

	
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			if sprite.animation != "WalkRight":
				sprite.play("WalkRight")
		else:
			if sprite.animation != "WalkLeft":
				sprite.play("WalkLeft")
	else:
		if direction.y > 0:
			if sprite.animation != "WalkForward":
				sprite.play("WalkForward")
		else:
			if sprite.animation != "WalkBack":
				sprite.play("WalkBack")

	move_and_slide()

	if global_position.distance_to(target) < 4:
		arrive()

func arrive():

	waiting = true

	velocity = Vector2.ZERO

	await get_tree().create_timer(patrol_wait_time).timeout

	patrol_index += 1

	if patrol_index >= patrol_points.size():
		patrol_index = 0

	waiting = false
