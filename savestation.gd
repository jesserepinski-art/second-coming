extends Node2D

@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
var busy := false

func interact() -> void:
	if busy:
		return

	busy = true
	sound.play()
	
	

	busy = false
	SaveManager.save_game()
	await Globals.textbox.start("", ["Game saved!"])
	await Globals.textbox.finished
	while Input.is_action_pressed("interact"):
		await get_tree().process_frame

	
