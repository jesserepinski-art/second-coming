extends Control
class_name BestiaryScreen

@onready var enemy_menu: Menu = $EnemyMenu
@onready var name_label: Label = $DetailPanel/NameLabel
@onready var description_label: Label = $DetailPanel/DescriptionLabel
@onready var photo_rect: TextureRect = $DetailPanel/PhotoRect
@onready var photo_anim: AnimatedSprite2D = $DetailPanel/PhotoAnim

var all_enemies: Array[BattleActor] = []

func _ready() -> void:
	_load_all_enemies("res://Enemies/")
	enemy_menu.button_pressed.connect(_on_enemy_selected)
	hide()

func _load_all_enemies(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var resource := load(path + file_name)
				if resource is BattleActor:
					all_enemies.append(resource)
			file_name = dir.get_next()

func open() -> void:
	show()
	await Menu.slide_fade_in(self)
	for button: QuestButton in enemy_menu.get_buttons():  
		var idx := button.get_index()
		var bestiary = Bestiary.new()
		if idx < all_enemies.size():
			var enemy := all_enemies[idx]
			button.visible = true
			button.text = enemy.name if bestiary.has_seen(enemy.name) else "???"
		else:
			button.visible = false
	enemy_menu.button_focus()

func close() -> void:
	await Menu.slide_fade_out(self)
	hide()

func _on_enemy_selected(_button: BaseButton, index: int) -> void:
	if index >= all_enemies.size():
		return
	var enemy := all_enemies[index]
	var bestiary = Bestiary.new()

	if not bestiary.has_seen(enemy.name):
		name_label.text = "???"
		description_label.text = "???"
		photo_anim.visible = false
		photo_rect.visible = true
		photo_rect.texture = null  
		return

	name_label.text = enemy.name
	description_label.text = enemy.description if "description" in enemy else ""
	photo_rect.visible = false
	photo_anim.visible = true
	if enemy.battle_sprite_frames:
		photo_anim.sprite_frames = enemy.battle_sprite_frames
		photo_anim.play("idle")
