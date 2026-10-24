extends Node

const POOL_SIZE := 8
var players: Array[AudioStreamPlayer] = []
var next_index := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		add_child(p)
		players.append(p)

func play(stream: AudioStream, volume_db: float = 0.0, pitch_variation: float = 0.0) -> void:
	if stream == null:
		return

	var p := players[next_index]
	next_index = (next_index + 1) % POOL_SIZE

	p.stream = stream
	p.volume_db = volume_db
	p.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	p.play()
