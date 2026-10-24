extends CharacterBody2D
@export var talk_sound: AudioStream
@export var cutscenedialogue: DialogueSequence = null
@export var basicdialogue: DialogueSequence = null
@export var dialogue: DialogueSequence = null
@export var walk_speed := 80.0
@export var patrol_path: Node2D
@export var patrol_wait_time := 1.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var cutscene_camera: CutsceneCamera = $"../CutsceneCamera"
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
	
	busy = true 

	
	if StoryFlags.has_flags(["clown_egg_init", "lost_in_a_dream_completed"]):
		await DialoguePlayer.play_sequence(dialogue)
	
	
	elif StoryFlags.has_flag("lost_in_a_dream_completed"):
		await _play_cutscene()
		
	
	
	else:
		await DialoguePlayer.play_sequence(basicdialogue)

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
func _on_dialogue_line_started(line: DialogueLine, player: Node) -> void:
	if line.camera_target == "":
		return

	var target_pos: Vector2 = cutscene_camera.global_position
	
	
	var cleaned_target = line.camera_target.to_lower().replace("_", "").replace(" ", "")

	
	if cleaned_target == "player":
		target_pos = player.global_position
	elif cleaned_target == "clownegg":
		target_pos = sprite.global_position
	else:
		
		var custom_target = get_tree().current_scene.find_child(line.camera_target, true, false)
		if custom_target and "global_position" in custom_target:
			target_pos = custom_target.global_position

	
	if line.camera_zoom > 0.0 and "zoom" in cutscene_camera:
		var tween = create_tween().set_parallel(true)
		tween.tween_property(cutscene_camera, "global_position", target_pos, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(cutscene_camera, "zoom", Vector2(line.camera_zoom, line.camera_zoom), 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		await tween.finished
	else:
		await cutscene_camera.pan_to(target_pos, 0.6)
func _play_cutscene() -> void:
	

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		await get_tree().process_frame
		player = get_tree().get_first_node_in_group("player")
	player.process_mode = Node.PROCESS_MODE_DISABLED

	await TransitionManager.fade_to_black(0.4)
	cutscene_camera.global_position = player.global_position
	cutscene_camera.make_current()
	await TransitionManager.fade_from_black(0.4)

	await cutscene_camera.pan_to(sprite.global_position, 1.5)

	await DialoguePlayer.play_sequence(cutscenedialogue, _on_dialogue_line_started.bind(player))
	

	await TransitionManager.fade_to_black(0.4)

	await TransitionManager.fade_from_black(0.4)
	QuestManager.start_quest("gather_allies")
	StoryFlags.set_flag("clown_egg_init")
	player.process_mode = Node.PROCESS_MODE_INHERIT
	var player_camera: Camera2D = player.get_node("Camera2D")
	player_camera.make_current()
	
