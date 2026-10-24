extends Node
class_name EdenArrivalCutscene

@onready var cutscene_camera: CutsceneCamera = $"../CutsceneCamera"

@onready var providence_actor: ProvidenceEdenActor = $ProvidenceEdenActor
@onready var potdaughter: CharacterBody2D = $"../PotDaughter"

func _ready() -> void:
	providence_actor.visible = true
	potdaughter.visible = false
	if not StoryFlags.has_flag("eden_arrival_played"):
		play_arrival()
		
	if StoryFlags.has_flag("worried_mother"):
		providence_actor.visible = false
		
	if StoryFlags.has_flag("dream_child_defeated"):
		potdaughter.visible = true

func play_arrival() -> void:
	

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		await get_tree().process_frame
		player = get_tree().get_first_node_in_group("player")
	player.process_mode = Node.PROCESS_MODE_DISABLED

	await TransitionManager.fade_to_black(0.4)
	cutscene_camera.global_position = player.global_position
	cutscene_camera.make_current()
	await TransitionManager.fade_from_black(0.4)

	await cutscene_camera.pan_to(providence_actor.global_position, 1.5)

	await Globals.textbox.start("Providence", ["..."])
	await Globals.textbox.finished

	

	var player_camera: Camera2D = player.get_node("Camera2D")
	player_camera.make_current()

	player.process_mode = Node.PROCESS_MODE_INHERIT
	QuestManager.start_quest("the_puppet")
	QuestManager.start_quest("the_judge")
	QuestManager.start_quest("the_siren")
	QuestManager.start_quest("the_horse")
	StoryFlags.set_flag("eden_arrival_played")
