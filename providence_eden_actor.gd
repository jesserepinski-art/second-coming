extends CharacterBody2D
class_name ProvidenceEdenActor
@export var dialogue: DialogueSequence
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var busy := false

func interact() -> void:
	if busy:
		return
	if StoryFlags.has_flag("providence_joined"):
		return

	busy = true
	await _play_join_cutscene()
	busy = false

func _play_join_cutscene() -> void:
	StoryFlags.set_flag("providence_joined")

	var player = get_tree().get_first_node_in_group("player")
	player.process_mode = Node.PROCESS_MODE_DISABLED
	
	await DialoguePlayer.play_sequence(dialogue)
	
	

	await TransitionManager.fade_to_black(0.4)
	Data.add_party_member(Data.PROVIDENCE_DATA)
	await TransitionManager.fade_from_black(0.4)
	StoryFlags.set_flag("worried_mother")
	QuestManager.start_quest("lost_in_a_dream")
	player.process_mode = Node.PROCESS_MODE_INHERIT
	queue_free()
