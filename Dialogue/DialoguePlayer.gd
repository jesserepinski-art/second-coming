extends Node

func _ready() -> void:
	pass
	

static func play_sequence(sequence: DialogueSequence, on_line_start: Callable = Callable()) -> void:
	for line: DialogueLine in sequence.lines:
		
		if on_line_start.is_valid():
			await on_line_start.call(line)

		
		var speaker_name := line.speaker.name if line.speaker else ""
		var portrait := line.speaker.portrait if line.speaker else null
		var sound := line.speaker.talk_sound if line.speaker else null

		await Globals.textbox.start(speaker_name, [line.text], portrait, sound)
		await Globals.textbox.finished
