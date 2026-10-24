extends Node
class_name ProvidenceIntroCutscene

@export var providence_data: BattleActor  
@onready var providence_actor: Node2D = $ProvidenceCutsceneActor 
@onready var providence_cutscene_actor: ProvidenceCutsceneActor = $ProvidenceCutsceneActor
@export var dialogue: DialogueSequence
func _ready() -> void:
	if StoryFlags.has_flag("providence_intro_played"):
		providence_actor.visible = false
	else:
		play_intro()

func play_intro() -> void:
	StoryFlags.set_flag("providence_intro_played")

	var player = get_tree().get_first_node_in_group("player")
	player.process_mode = Node.PROCESS_MODE_DISABLED

	await DialoguePlayer.play_sequence(dialogue)



	await TransitionManager.fade_to_black(0.6)
	providence_actor.visible = false  
	await TransitionManager.fade_from_black(0.6)
	QuestManager.start_quest("knockin_on_heavens_door")
	player.process_mode = Node.PROCESS_MODE_INHERIT
