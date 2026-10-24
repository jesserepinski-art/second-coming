extends Node2D

@export var level_music: AudioStream
@export var ambient_sound: AudioStream = null
@export var ambient_volume_db: float = -10.0
@export var level_music_volume_db: float = -10.0
func _ready():
	var level_manager = get_tree().root.get_node("Main/LevelManager")
	level_manager.set_level_music(level_music, level_music_volume_db)
