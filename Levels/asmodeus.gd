extends CharacterBody2D
class_name AsmodeusNPC

@export var battle_actors: Array[BattleActor]
@export var theme_music: AudioStream
@export var theme_music_volume_db: float = -10.0
@export var battle_music: AudioStream
@export var battle_music_volume_db: float = -10.0
@export var custom_background: PackedScene = null
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var busy := false

func interact() -> void:
	if busy:
		return
	if StoryFlags.has_flag("asmodeus_joined"):
		return

	busy = true
	await _play_encounter()
	busy = false

func _play_encounter() -> void:
	
	var player = get_tree().get_first_node_in_group("player")
	player.process_mode = Node.PROCESS_MODE_DISABLED

	MusicManager.play(theme_music, theme_music_volume_db)

	await Globals.textbox.start("Asmodeus", ["Let's fight."], Data.ASMODEUS_DATA.portrait)
	await Globals.textbox.finished
	await Globals.textbox.start("Dama", ["???"], Data.DAMA_DATA.portrait)
	await Globals.textbox.finished
	await Globals.textbox.start("Asmodeus", ["You seem strong, and I have nothing better to do"], Data.ASMODEUS_DATA.portrait)
	await Globals.textbox.finished
	await Globals.textbox.start("Dama", ["Go to Hell"], Data.DAMA_DATA.portrait)
	await Globals.textbox.finished
	await Globals.textbox.start("Asmodeus", ["Dipshit, what do you think I'm doing here?"], Data.ASMODEUS_DATA.portrait)
	await Globals.textbox.finished
	await Globals.textbox.start("Asmodeus", ["If it wasn't for that ass hat Abaddon..."], Data.ASMODEUS_DATA.portrait)
	await Globals.textbox.finished
	await Globals.textbox.start("Asmodeus", ["I might not be up here right now"], Data.ASMODEUS_DATA.portrait)
	await Globals.textbox.finished
	await Globals.textbox.start("Asmodeus", ["So let's fight"], Data.ASMODEUS_DATA.portrait)
	await Globals.textbox.finished
	await Globals.textbox.start("Dama", ["Eh, might as well..."], Data.DAMA_DATA.portrait)
	await Globals.textbox.finished

	Encounter.enemies = battle_actors.duplicate()
	Encounter.enemy_node = self
	Encounter.return_scene = get_tree().current_scene.scene_file_path
	Encounter.battle_music = battle_music
	Encounter.battle_music_volume = battle_music_volume_db
	Encounter.battle_background = custom_background

	await BattleManager.begin_battle(Encounter.enemies)

	StoryFlags.set_flag("asmodeus_joined")
	Data.add_party_member(Data.ASMODEUS_DATA)

	player.process_mode = Node.PROCESS_MODE_INHERIT
	queue_free()
