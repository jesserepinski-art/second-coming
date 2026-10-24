extends Area2D
class_name VideoCutscene

@export var cutscene_flag: String = ""
@export var video: VideoStream
@onready var video_player: VideoStreamPlayer = $Area2D/VideoStreamPlayer

var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if StoryFlags.has_flag(cutscene_flag):
		queue_free()

func _on_body_entered(body: Node) -> void:
	if triggered or not body.is_in_group("player"):
		return
	triggered = true
	StoryFlags.set_flag(cutscene_flag)
	await _play_cutscene()

func _play_cutscene() -> void:
	var player = get_tree().get_first_node_in_group("player")
	player.process_mode = Node.PROCESS_MODE_DISABLED

	await TransitionManager.fade_to_black(0.5)
	await MusicManager.fade_out(0.5)
	await AmbientManager.fade_out(0.5)

	video_player.stream = video
	video_player.visible = true
	video_player.play()
	await video_player.finished
	video_player.visible = false

	var level_manager = get_tree().root.get_node("Main/LevelManager")
	await MusicManager.fade_in(level_manager.current_level_music, level_manager.current_level_music_volume, 0.5)
	await AmbientManager.fade_in(level_manager.current_level.ambient_sound, level_manager.current_level.ambient_volume_db, 0.5)
	await TransitionManager.fade_from_black(0.5)

	player.process_mode = Node.PROCESS_MODE_INHERIT
