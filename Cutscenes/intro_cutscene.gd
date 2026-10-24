extends Node
class_name IntroCutscene

const WAKE_UP_SCENE := preload("res://Cutscenes/WakeUpScene.tscn")
const DREAM_SCENE := preload("res://Cutscenes/damadream3d.tscn")
@onready var knock_sound: AudioStreamPlayer = $KnockSound
@onready var dream: VideoStreamPlayer = $VideoStreamPlayer
@onready var music: AudioStreamPlayer = $CutsceneMusic
@onready var ambience: AudioStreamPlayer = $CutsceneAmbience
@onready var wake_up_scene: Node3D = $"../WakeUpScene"
@onready var wake_up_anim: AnimationPlayer = $"../WakeUpScene/Dama3D/AnimationPlayer"

func _ready() -> void:
	if not StoryFlags.has_flag("intro_played"):
		play_intro()

func play_intro() -> void:
	StoryFlags.set_flag("intro_played")
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		await get_tree().process_frame
		player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("IntroCutscene: could not find player node")
		return
	var camera = get_tree().root.get_node("Main/Player/Camera2D")
	camera.enabled = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().root.get_node("Main/SubViewportContainer").visible = true
	music.play()
	ambience.play()

	var dream_scene_instance = DREAM_SCENE.instantiate()
	get_tree().root.get_node("Main/SubViewportContainer/SubViewport/CutsceneLayer3D").add_child(dream_scene_instance)
	await get_tree().process_frame
	dream_scene_instance.get_node("Camera3D").make_current()
	
	var dream_anim: AnimationPlayer = dream_scene_instance.get_node("AnimationPlayer")
	dream_anim.play("damadream")
	var run_anim: AnimationPlayer = dream_scene_instance.get_node("Dama3D/AnimationPlayer")
	run_anim.play("Armature|ArmatureAction_004")
	await run_anim.animation_finished
	run_anim.play("Armature|ArmatureAction_004")
	await run_anim.animation_finished
	run_anim.play("Armature|ArmatureAction_005")
	await run_anim.animation_finished
	await dream_anim.animation_finished
	
	music.stop()
	ambience.stop()
	
	await TransitionManager.close_eyes()
	dream.visible = false
	var wake_up_instance = WAKE_UP_SCENE.instantiate()
	get_tree().root.get_node("Main/SubViewportContainer/SubViewport/CutsceneLayer3D").add_child(wake_up_instance)
	dream_scene_instance.queue_free()
	await get_tree().process_frame
	wake_up_instance.get_node("Camera3D").make_current()
	

	var wake_up_anim: AnimationPlayer = wake_up_instance.get_node("Dama3D/AnimationPlayer")
	wake_up_anim.play("Armature|ArmatureAction_003")
	await wake_up_anim.animation_finished

	await TransitionManager.close_eyes()
	get_tree().root.get_node("Main/SubViewportContainer").visible = false
	wake_up_instance.queue_free()
	camera.enabled = true
	camera.make_current()
	await TransitionManager.open_eyes()

	knock_sound.play()
	await Globals.textbox.start("", ["(A knock at the door.)"])
	await Globals.textbox.finished

	player.process_mode = Node.PROCESS_MODE_INHERIT

	var level_manager = get_tree().root.get_node("Main/LevelManager")
	level_manager.set_level_music(level_manager.current_level.level_music, level_manager.current_level.level_music_volume_db)
