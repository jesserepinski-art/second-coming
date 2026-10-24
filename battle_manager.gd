extends Node
var current_battle: Control = null
var _ending := false
var _starting := false
var level_manager: Node:
	get:
		return get_tree().root.get_node_or_null("Main/LevelManager")

var player: Node:
	get:
		return get_tree().root.get_node_or_null("Main/Player")
@export var battle_intro_tip:= preload("res://Tips/BattleIntroData.tres")
func _ready():
	pass

signal battle_ended

func begin_battle(encounter):

	if current_battle or _starting:
		return
	_starting = true
	await TransitionManager.close_clouds()
	current_battle = preload("res://battle.tscn").instantiate()
	_starting = false
	await TransitionManager.close_clouds()
	current_battle = preload("res://battle.tscn").instantiate()
	level_manager.current_level.process_mode = Node.PROCESS_MODE_DISABLED
	player.process_mode = Node.PROCESS_MODE_DISABLED
	player.visible = false
	var layer := get_tree().root.get_node("Main/BattleLayer")
	layer.add_child(current_battle)
	var battle_camera := current_battle.get_node("Camera2D")
	battle_camera.make_current()
	MusicManager.play(Encounter.battle_music, Encounter.battle_music_volume)
	await TransitionManager.open_clouds()
	
	await Globals.tip_screen.show_once(battle_intro_tip)


	await battle_ended

func end_battle() -> void:
	if current_battle == null or _ending:
		return
	_ending = true
	await TransitionManager.close_clouds()
	Menu.tree.clear()
	if is_instance_valid(current_battle):
		current_battle.queue_free()
	current_battle = null
	_ending = false
	MusicManager.play(level_manager.current_level_music, level_manager.current_level_music_volume)
	level_manager.current_level.process_mode = Node.PROCESS_MODE_INHERIT
	player.process_mode = Node.PROCESS_MODE_INHERIT
	player.visible = true
	var player_camera := player.get_node("Camera2D")
	player_camera.make_current()
	await TransitionManager.open_clouds()

	battle_ended.emit()
func defeat() -> void:
	await TransitionManager.fade_to_black(1.0)
	MusicManager.stop()
	AmbientManager.stop()
	Menu.tree.clear()
	get_tree().paused = false
	current_battle = null  

	await Globals.game_over_screen.show_screen()  

	if Globals.game_over_screen.chose_continue and SaveManager.load_game(SaveManager.current_slot):
		get_tree().change_scene_to_file("res://Main.tscn")
	else:
		get_tree().change_scene_to_file("res://MainMenu.tscn")
