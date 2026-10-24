extends Node3D
class_name ModelCutscene

@onready var model_anim: AnimationPlayer = $Dama3D/AnimationPlayer  
@export var animation_name: StringName = "Armature|ArmatureAction_003"

func _ready() -> void:
	if StoryFlags.has_flag("dama_wake_up"):
		queue_free()
		return
	play_cutscene()

func play_cutscene() -> void:
	StoryFlags.set_flag("dama_wake_up")

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.process_mode = Node.PROCESS_MODE_DISABLED

	await TransitionManager.close_eyes()
	
	await TransitionManager.open_eyes()

	model_anim.play(animation_name)
	await model_anim.animation_finished

	await TransitionManager.close_eyes()
	
	await TransitionManager.open_eyes()

	if player:
		player.process_mode = Node.PROCESS_MODE_INHERIT
