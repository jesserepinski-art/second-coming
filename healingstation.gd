extends Node2D

@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
var busy := false
func interact() -> void:
	if busy:
		return

	busy = true
	sound.play()
	await Globals.textbox.start("", ["You feel like $100 bucks!"])
	await Globals.textbox.finished
	while Input.is_action_pressed("interact"):
		await get_tree().process_frame

	busy = false
	heal_party()

func heal_party() -> void:
	for member in Data.party:
		if member.has_method("healhurt"):
			member.healhurt(member.hp_max)
	
