class_name Sign
extends Interactable

@export_multiline var lines: Array[String] = []

var busy := false

func interact():

	if busy:
		return

	busy = true

	print("Globals.textbox =", Globals.textbox)
	print("Type =", typeof(Globals.textbox))

	if Globals.textbox:
		print("Scene path:", Globals.textbox.scene_file_path)
		print("Instance ID:", Globals.textbox.get_instance_id())

	Globals.textbox.start("", lines)
	await Globals.textbox.finished

	
	while Input.is_action_pressed("interact"):
		await get_tree().process_frame

	busy = false
