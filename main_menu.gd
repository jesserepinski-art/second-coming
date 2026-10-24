extends Node3D
@onready var menu: Control = $UI/MainButtons
@onready var title: Label = $UI/Title
@onready var dama_anim: AnimationPlayer = $Stage/Dama3D/AnimationPlayer
@onready var menu_anim: AnimationPlayer = $MenuAnimator
@export var music: AudioStream = null
@export var music_volume_db: float = -10.0

var _busy := false
func _ready() -> void:
	MusicManager.play(music, music_volume_db)
	menu_anim.play("idle")
	
	
func _on_continue_button_pressed() -> void:
	if _busy:
		return
	if SaveManager.load_game(SaveManager.latest_slot()):
		_busy = true
		await Menu.slide_fade_out(menu)
		await Menu.slide_fade_out(title)
		menu_anim.play("Continue")
		await menu_anim.animation_finished
		MusicManager.stop()
		
		get_tree().change_scene_to_file("res://Main.tscn")

func _on_quit_button_pressed() -> void:
	MusicManager.stop()
	get_tree().quit()


func _on_new_game_button_pressed() -> void:
	if _busy:
		return
	_busy = true
	await Menu.slide_fade_out(menu)
	await Menu.slide_fade_out(title)
	menu_anim.play("NewGame")
	await menu_anim.animation_finished
	SaveManager.new_game()
	MusicManager.stop()
	
	get_tree().change_scene_to_file("res://Main.tscn")
