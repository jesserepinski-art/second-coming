extends Area2D
@export var open_sound: AudioStream
@export var open_sound_volume_db: float = -10.0
@export var close_sound: AudioStream
@export var close_sound_volume_db: float = -10.0
@export var destination_path: String = ""
@export var spawn_point: String = "Entrance"
var entered := false
var ready_to_trigger := false

func _ready():
	body_entered.connect(_on_body_entered)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	ready_to_trigger = true

func _on_body_entered(body):
	print("Door triggered. Body: ", body.name, " at position: ", body.global_position, " Door position: ", global_position)
	if BattleManager.current_battle:
		return
	if entered or not body.is_in_group("player"):
		return
	if entered:
		return
	if body is CharacterBody2D:
		print("Player entered!")
	else:
		return
	if entered or not ready_to_trigger:
		return
	entered = true
	set_deferred("monitoring", false)
	SfxManager.play(open_sound, open_sound_volume_db)
	if destination_path.is_empty():
		push_error("Door has no destination_path set!")
		return

	var scene: PackedScene = load(destination_path)
	var spawn := spawn_point
	var level_manager = get_tree().root.get_node("Main/LevelManager")
	await level_manager.change_room(scene, spawn)
	queue_free()
