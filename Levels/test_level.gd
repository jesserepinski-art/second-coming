extends Node2D
@export var level_music: AudioStream
@export var ambient_sound: AudioStream = null
@export var ambient_volume_db: float = -10.0
@export var zone_level: int = 1
@export var level_music_volume_db: float = -10.0


@export var location_name: String = ""
@export var show_banner: bool = true

func _ready():
	var level_manager = get_tree().root.get_node("Main/LevelManager")
	level_manager.set_level_music(level_music, level_music_volume_db)

	if location_name != "":
		QuestManager.notify_location_reached(location_name)
	if location_name != "" and show_banner:
		await get_tree().create_timer(0.8).timeout
		Globals.location_banner.show_location(location_name)
