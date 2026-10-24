extends Node3D
class_name SpellLearnedCutscene

@onready var main_anim: AnimationPlayer = $AnimationPlayer 
@onready var camera: Camera3D = $Camera3D

func play_cutscene() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.process_mode = Node.PROCESS_MODE_DISABLED

	await TransitionManager.fade_to_black()
	camera.make_current()
	await TransitionManager.fade_from_black()

	main_anim.play("SpellLearned")
	await main_anim.animation_finished

	await TransitionManager.fade_to_black()
	
	await TransitionManager.fade_from_black()

	if player:
		player.process_mode = Node.PROCESS_MODE_INHERIT
