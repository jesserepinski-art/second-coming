extends Node
@onready var ambient: AudioStreamPlayer = $Ambient

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func play(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		stop()
		return

	if ambient.stream == stream and ambient.playing:
		return

	ambient.stream = stream
	ambient.volume_db = volume_db
	ambient.play()

func stop() -> void:
	ambient.stop()

func fade_out(duration: float = 0.5) -> void:
	var tween := create_tween()
	tween.tween_property(ambient, "volume_db", -80.0, duration)
	await tween.finished
	ambient.stop()

func fade_in(stream: AudioStream, volume_db: float, duration: float = 0.5) -> void:
	if stream == null:
		return
	ambient.stream = stream
	ambient.volume_db = -80.0
	ambient.play()
	var tween := create_tween()
	tween.tween_property(ambient, "volume_db", volume_db, duration)
	await tween.finished
