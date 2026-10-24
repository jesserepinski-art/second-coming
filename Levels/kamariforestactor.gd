extends CharacterBody2D
class_name KamariForestActor
@export var storydialogue: DialogueSequence
@export var initialdialogue: DialogueSequence
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var busy := false
@export var ally_data: BattleActor

func _ready() -> void:
	if Data.is_in_party(ally_data.name):
		queue_free()

func interact() -> void:
	if busy:
		return
	if StoryFlags.has_flag("kamari_joined"):
		return
	if StoryFlags.has_flag("lost_in_a_dream_completed"):
		busy = true
		await _play_join_cutscene()
		busy = false
	else:
		busy = true
		await DialoguePlayer.play_sequence(initialdialogue)
		await get_tree().process_frame 
		busy = false
	

func _play_join_cutscene() -> void:
	StoryFlags.set_flag("kamari_joined")

	var player = get_tree().get_first_node_in_group("player")
	player.process_mode = Node.PROCESS_MODE_DISABLED

	await DialoguePlayer.play_sequence(storydialogue)

	

	await TransitionManager.fade_to_black(0.4)
	if not Data.recruit(ally_data):
		var out: BattleActor = await Globals.party_picker.pick()
		if out == null:
			return
		var home_pos := out.name  
		Data.dismiss(out)
		Data.recruit(ally_data)
	await TransitionManager.fade_from_black(0.4)
	
	
	player.process_mode = Node.PROCESS_MODE_INHERIT
	queue_free()
