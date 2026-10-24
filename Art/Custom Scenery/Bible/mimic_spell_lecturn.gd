extends Node2D
class_name MimicLecturn

@export var battle_actors: Array[BattleActor]
@export var enemy_level: int = 1
@export var flag_id: String = ""  
@export var battle_music: AudioStream
@export var battle_music_volume_db: float = -10.0
@export var custom_background: PackedScene = null
@onready var lecturn: Sprite2D = $Lecturn
@onready var bible: AnimatedSprite2D = $Bible
@onready var sound: AudioStreamPlayer = $AudioStreamPlayer
var busy := false

func _ready() -> void:
	if flag_id != "" and StoryFlags.has_flag(flag_id):
		return

func interact() -> void:
	if busy:
		return
	busy = true
	bible.play("reveal")
	sound.play()
	await bible.animation_finished
	var scaled: Array[BattleActor] = []
	for base_actor in battle_actors:
		var instance := base_actor.copy()
		instance.scale_to_level(enemy_level)
		scaled.append(instance)

	Encounter.enemies = scaled
	Encounter.enemy_node = self
	Encounter.battle_music = battle_music
	Encounter.battle_music_volume = battle_music_volume_db
	Encounter.battle_background = custom_background
	Encounter.won = false

	await BattleManager.begin_battle(Encounter.enemies)

	if Encounter.won:
		if flag_id != "":
			StoryFlags.set_flag(flag_id)
		queue_free()
	else:
		busy = false
