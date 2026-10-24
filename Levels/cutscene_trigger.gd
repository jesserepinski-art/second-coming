extends Area2D
class_name DreamForestCutscene

@export var battle_actors: Array[BattleActor]
@export var theme_music: AudioStream
@export var theme_music_volume_db: float = -10.0
@export var battle_music: AudioStream
@export var battle_music_volume_db: float = -10.0
@export var custom_background: PackedScene = null
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var dialogue: DialogueSequence
@export var postbattledialogue: DialogueSequence
@export var providencedialogue: DialogueSequence
@export var cutscene_flag: String = ""
@onready var cutscene_camera: CutsceneCamera = $"../CutsceneCamera"
@onready var dream_child: CharacterBody2D = $"../DreamChild"
@onready var potdaughter: CharacterBody2D = $"../PotDaughter"
var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if StoryFlags.has_flag(cutscene_flag):
		queue_free()
func _on_dialogue_line_started(line: DialogueLine, player: Node) -> void:
	if line.camera_target == "":
		return

	var target_pos: Vector2 = cutscene_camera.global_position
	
	
	var cleaned_target = line.camera_target.to_lower().replace("_", "").replace(" ", "")

	
	if cleaned_target == "player":
		target_pos = player.global_position
	elif cleaned_target == "dreamchild":
		target_pos = dream_child.global_position
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
		
func _on_body_entered(body: Node) -> void:
	if triggered or not body.is_in_group("player"):
		return
	triggered = true
	StoryFlags.set_flag(cutscene_flag)
	await _play_cutscene()

func _play_cutscene() -> void:
	MusicManager.play(theme_music, theme_music_volume_db)

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		await get_tree().process_frame
		player = get_tree().get_first_node_in_group("player")
	player.process_mode = Node.PROCESS_MODE_DISABLED

	await TransitionManager.fade_to_black(0.4)
	cutscene_camera.global_position = player.global_position
	cutscene_camera.make_current()
	await TransitionManager.fade_from_black(0.4)

	await cutscene_camera.pan_to(dream_child.global_position, 1.5)

	await DialoguePlayer.play_sequence(dialogue, _on_dialogue_line_started.bind(player))
	
	Encounter.enemies = battle_actors.duplicate()
	Encounter.enemy_node = self
	Encounter.return_scene = get_tree().current_scene.scene_file_path
	Encounter.battle_music = battle_music
	Encounter.battle_music_volume = battle_music_volume_db
	Encounter.battle_background = custom_background

	await BattleManager.begin_battle(Encounter.enemies)
	player.process_mode = Node.PROCESS_MODE_DISABLED
	await DialoguePlayer.play_sequence(postbattledialogue, _on_dialogue_line_started.bind(player))
	var tween = create_tween()
	
	
	tween.tween_property(dream_child, "modulate", Color(1, 1, 1, 0), 1.0)
	
	await TransitionManager.fade_to_black(0.4)

	await TransitionManager.fade_from_black(0.4)
	tween.tween_property(potdaughter, "modulate", Color(1, 1, 1, 0), 1.0)
	await DialoguePlayer.play_sequence(providencedialogue, _on_dialogue_line_started.bind(player))
	StoryFlags.set_flag("dream_child_defeated")
	
	player.process_mode = Node.PROCESS_MODE_INHERIT
	var player_camera: Camera2D = player.get_node("Camera2D")
	player_camera.make_current()
	
