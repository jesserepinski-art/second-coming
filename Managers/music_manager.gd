extends Node
@onready var music: AudioStreamPlayer = $Music

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func play(track: AudioStream, volume_db: float = 0.0) -> void:
	if track == null:
		return
	if music.stream == track and music.playing:
		music.volume_db = volume_db 
		return
	music.stream = track
	music.volume_db = volume_db
	music.play()

func set_volume(volume_db: float) -> void:
	music.volume_db = volume_db

func stop() -> void:
	music.stop()

func pause() -> void:
	music.stream_paused = true

func resume() -> void:
	music.stream_paused = false

func fade_out(duration: float = 0.5) -> void:
	var tween := create_tween()
	tween.tween_property(music, "volume_db", -80.0, duration)
	await tween.finished
	music.stop()

func fade_in(track: AudioStream, volume_db: float, duration: float = 0.5) -> void:
	music.stream = track
	music.volume_db = -80.0
	music.play()
	var tween := create_tween()
	tween.tween_property(music, "volume_db", volume_db, duration)
	await tween.finished
