extends Node2D
class_name SpellLecturn

@export var spell: Item
@export var flag_id: String = ""  
@export var cutscene_scene: PackedScene

@onready var bible: AnimatedSprite2D = $Bible
@onready var particles: CPUParticles2D = $Bible/GPUParticles2D

var busy := false

func _ready() -> void:
	if StoryFlags.has_flag(flag_id):
		particles.emitting = false

func interact() -> void:
	if busy or StoryFlags.has_flag(flag_id):
		return
	busy = true
	await _play_sequence()
	busy = false

func _play_sequence() -> void:
	StoryFlags.set_flag(flag_id)
	particles.emitting = false
	
	var player = get_tree().get_first_node_in_group("player")
	var player_camera: Camera2D = player.get_node("Camera2D")
	player.process_mode = Node.PROCESS_MODE_DISABLED
	
	await TransitionManager.fade_to_black()
	player_camera.enabled = false
	get_tree().root.get_node("Main/SubViewportContainer").visible = true
	var cutscene = cutscene_scene.instantiate()
	get_tree().root.get_node("Main/SubViewportContainer/SubViewport/CutsceneLayer3D").add_child(cutscene)
	await get_tree().process_frame
	cutscene.get_node("Camera3D").make_current()
	await TransitionManager.fade_from_black()

	var main_anim: AnimationPlayer = cutscene.get_node("AnimationPlayer")
	main_anim.play("SpellLearned")
	await main_anim.animation_finished

	await TransitionManager.fade_to_black()
	get_tree().root.get_node("Main/SubViewportContainer").visible = false
	cutscene.queue_free()

	player_camera.enabled = true
	player_camera.make_current()
	await TransitionManager.fade_from_black()

	for actor: BattleActor in Data.party:
		actor.spells.append(spell)

	await Globals.textbox.start("", ["You learned %s!" % spell.display_name])
	await Globals.textbox.finished

	player.process_mode = Node.PROCESS_MODE_INHERIT
