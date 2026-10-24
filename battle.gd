extends Control

const ENEMY_SCENE := preload("res://enemy.tscn")

const Actions: Dictionary = EventQueue.Actions

var party: Array = Data.party
var current_action: EventQueue.Actions = -1
var current_player_index: int = -1
var current_action_data: Resource = null

@onready var event_queue: EventQueue = $EventQueue
@onready var options: Menu = $MarginContainer/Options
@onready var player_windows: PlayerWindows = $MarginContainer/PlayerWindows
@onready var enemies: Menu = $Enemies
@onready var textbox: Textbox = Globals.textbox
@onready var inventory: InventoryMenu = $MarginContainer/Inventory
@onready var spell_menu: SpellMenu = $MarginContainer/SpellMenu
@onready var sequence_player: AnimationPlayer = $SequencePlayer
@onready var background_slot: ColorRect = $Background  
var default_background_scene: PackedScene = preload("res://background.tscn")
func _ready() -> void:
	_apply_background()
	spawn_encounter()
	enemies.rebuild_buttons()
	enemies.connect_to_buttons(self)
	options.connect_to_buttons(self)
	inventory.connect_to_buttons(self)
	spell_menu.button_pressed.connect(_on_spell_menu_button_pressed)
	print(
	"SpellMenu connected: ",
	spell_menu.button_pressed.is_connected(
		Callable(self, "_on_spell_menu_button_pressed")
	)
)
	goto_next_player()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if enemies.close() \
		or player_windows.close() \
		or inventory.close(true) \
		or spell_menu.close(true):

			options.show()
			options.button_focus()

		elif options.menu_is_focused():
			event_queue.pop_back()
			goto_next_player(-1)
		else:
			return

		get_viewport().set_input_as_handled()
func goto_next_player(dir: int = 1) -> void:
	dir = clampi(dir, -1, 1)
	current_player_index += dir
	current_player_index = clampi(current_player_index, 0, party.size())
	inventory.hide()
	
	
	
	if current_player_index >= party.size():
		for enemy: Enemy in enemies.get_buttons():
			var actor: BattleActor = enemy.data
			print("Enemy in turn loop: ", actor.name if actor else "null", " defeated: ", actor.is_defeated() if actor else "N/A")

			if actor == null or actor.is_defeated():
				continue




			var choices: Array[Resource] = []

			for attack in actor.attacks:
				choices.append(attack)

			for spell in actor.spells:
				choices.append(spell)

			if choices.is_empty():
				continue

			var chosen : Resource = choices.pick_random()

			if chosen is AttackData:
				actor.queued_action = Actions.FIGHT
				actor.queued_payload = chosen

			elif chosen is Item:
				actor.queued_action = Actions.MAGIC
				actor.queued_payload = chosen
			actor.queued_target = get_random_target(actor, actor.queued_payload)
			
		event_queue.build_turn_order(get_turn_order())
		options.hide()
		
		
		var current_focus = get_viewport().gui_get_focus_owner()
		if current_focus:
			current_focus.release_focus()
		
		
		player_windows.activate(-1)
		player_windows.lower()
		await event_queue.run()

		await show_battle_observation()

		current_player_index = 0
	
	current_action = -1
	current_action_data = null
	player_windows.activate(current_player_index)
	options.button_focus()

func _apply_background() -> void:
	var scene_to_use: PackedScene = Encounter.battle_background if Encounter.battle_background else default_background_scene

	var parent := background_slot.get_parent()
	var index := background_slot.get_index()
	background_slot.queue_free()

	var new_bg := scene_to_use.instantiate()
	new_bg.name = "Background"
	parent.add_child(new_bg)
	parent.move_child(new_bg, index)

func show_battle_observation() -> void:

	var alive: Array[BattleActor] = []

	for enemy: Enemy in enemies.get_buttons():
		if enemy.data and !enemy.data.is_defeated():
			alive.append(enemy.data)

	if alive.is_empty():
		return

	var chosen: BattleActor = alive.pick_random()
	var observation: String = chosen.get_battle_observation()

	if observation.is_empty():
		return

	textbox.observe(observation)
	
func _on_options_button_pressed(button: BaseButton, _index: int) -> void:
	
	match button.text:
		"Fight":
			player_windows.raise()
			var actor: BattleActor = party[current_player_index]

			if !actor.attacks.is_empty():
				prepare_action(Actions.FIGHT, actor.attacks[0])

			options.close()
			for enemy: Enemy in enemies.get_buttons():
				enemy.focus_mode = Control.FOCUS_ALL

			enemies.button_focus()

		"Magic":
			player_windows.raise()
			current_action = Actions.MAGIC

			var actor: BattleActor = party[current_player_index]

			spell_menu.spells = actor.spells
			await spell_menu.refresh()

			options.close()
			spell_menu.button_focus()

		"Item":
			player_windows.raise()
			current_action = Actions.ITEM
			
			 
			inventory.inventory = party[current_player_index].inventory
			
			if inventory.has_method("refresh"):
				await inventory.refresh()

			options.close() 
			inventory.button_focus(0)
		"Run":
			BattleManager.end_battle()
func _on_enemies_button_focused(button: BaseButton, index: int) -> void:
	pass
	
func _on_inventory_button_pressed(button: BaseButton, _index: int) -> void:
	
	if button and "item" in button and button.item != null:
		current_action_data = button.item
		inventory.close(true)

		match button.item.target:
			Item.TargetType.ENEMY, Item.TargetType.ALL_ENEMIES:
				enemies.button_focus()

			Item.TargetType.ALLY, Item.TargetType.ALL_ALLIES:
				player_windows.button_focus(current_player_index)

			Item.TargetType.SELF:
				_on_player_windows_button_pressed(
					player_windows.get_buttons()[current_player_index],
					current_player_index
				)
	else:
		print("Player clicked an empty item slot, ignoring input.")

func _on_enemies_button_pressed(button: BaseButton, _index: int) -> void:

	

	party[current_player_index].queued_action = current_action
	party[current_player_index].queued_target = button.data
	party[current_player_index].queued_payload = current_action_data

	enemies.close()
	goto_next_player()
func _on_player_windows_button_pressed(button: BaseButton, _index: int) -> void:
	
	var current_actor: BattleActor = party[current_player_index]
	
	current_actor.queued_action = current_action
	current_actor.queued_target = button.data
	current_actor.queued_payload = current_action_data

	
	player_windows.close() 
	
	
	goto_next_player()

func prepare_action(action: EventQueue.Actions, data: Resource) -> void:
	current_action = action
	current_action_data = data
func _on_spell_menu_button_pressed(button: BaseButton, _index: int) -> void:
	current_action_data = button.item
	spell_menu.close(true)
	
	match button.item.target:
		Item.TargetType.ENEMY:
			enemies.button_focus()
		Item.TargetType.ALLY:
			player_windows.button_focus(current_player_index)
		Item.TargetType.SELF:
			_on_player_windows_button_pressed(
				player_windows.get_buttons()[current_player_index],
				current_player_index
			)
		Item.TargetType.ALL_ENEMIES:
			_on_enemies_button_pressed(enemies.get_buttons()[0], 0)
		Item.TargetType.ALL_ALLIES:
			_on_player_windows_button_pressed(player_windows.get_buttons()[0], 0)

	return
func get_turn_order() -> Array[BattleActor]:
	var order: Array[BattleActor] = []

	for actor: BattleActor in party:
		if actor and !actor.is_defeated():
			order.append(actor)

	for enemy: Enemy in enemies.get_buttons():
		if enemy.data and !enemy.data.is_defeated():
			order.append(enemy.data)

	return order
func get_random_target(caster: BattleActor, payload: Resource) -> BattleActor:
	var target_type: Item.TargetType

	if payload is Item:
		target_type = payload.target
	else:
		target_type = Item.TargetType.ENEMY

	var caster_is_player := Data.party.has(caster)

	match target_type:

		Item.TargetType.SELF:
			return caster

		Item.TargetType.ALLY, Item.TargetType.ALL_ALLIES:
			if caster_is_player:
				var allies := Data.party.filter(func(a): return !a.is_defeated())
				if allies.is_empty():
					return null
				return allies.pick_random()
			else:
				var allies: Array[BattleActor] = []
				for enemy: Enemy in enemies.get_buttons():
					if enemy.data and !enemy.data.is_defeated():
						allies.append(enemy.data)
				if allies.is_empty():
					return null
				return allies.pick_random()

		Item.TargetType.ENEMY, Item.TargetType.ALL_ENEMIES:
			if caster_is_player:
				var enemy_targets: Array[BattleActor] = []
				for enemy: Enemy in enemies.get_buttons():
					if enemy.data and !enemy.data.is_defeated():
						enemy_targets.append(enemy.data)
				if enemy_targets.is_empty():
					return null
				return enemy_targets.pick_random()
			else:
				var party_targets := Data.party.filter(func(a): return !a.is_defeated())
				if party_targets.is_empty():
					return null
				return party_targets.pick_random()

	return null
func spawn_encounter():
	var bestiary = Bestiary.new()
	print("Encounter.enemies size: ", Encounter.enemies.size())
	for actor in Encounter.enemies:
		print(" - ", actor.name)
		bestiary.mark_seen(actor.name)

	for child in enemies.get_children():
		if child is Enemy or child is BossEnemy:
			child.queue_free()


	for actor in Encounter.enemies:
		var enemy_scene: PackedScene = actor.custom_battle_rig if actor.custom_battle_rig else ENEMY_SCENE
		var enemy = enemy_scene.instantiate()
		enemy.data = actor
		enemies.add_child(enemy)
		enemy.focus_mode = Control.FOCUS_NONE

	layout_enemies()
	enemies.rebuild_buttons()
	setup_enemy_focus()
func layout_enemies():
	var positions := [
		Vector2(50, 86),
		Vector2(250, 105),
		Vector2(457, 86)
	]
	var center_position := Vector2(250, 105)  

	var enemy_children: Array = []
	for child in enemies.get_children():
		if child is Enemy:
			enemy_children.append(child)

	if enemy_children.size() == 1:
		enemy_children[0].position = center_position
		print("Before:", enemy_children[0].position)
		await get_tree().process_frame
		print("After:", enemy_children[0].position)
		return

	var index := 0
	for child in enemy_children:
		if index < positions.size():
			child.position = positions[index]
			print("Before:", child.position)
			await get_tree().process_frame
			print("After:", child.position)
		index += 1
func setup_enemy_focus() -> void:
	var buttons := enemies.get_buttons()

	var count := buttons.size()

	if count <= 1:
		return

	for i in range(count):
		var current := buttons[i] as BaseButton
		var left := buttons[(i - 1 + count) % count] as BaseButton
		var right := buttons[(i + 1) % count] as BaseButton

		current.focus_neighbor_left = current.get_path_to(left)
		current.focus_neighbor_right = current.get_path_to(right)
func end_battle(result:String="run"):

	get_tree().paused = false

	queue_free()
func check_battle_end() -> bool:
	
	for enemy: Enemy in enemies.get_buttons():
		if enemy.data and !enemy.data.is_defeated():
			return false

	
	await battle_won()
	return true
	
func battle_won() -> void:
	var xp_total := 0
	var gold_total := 0
	for actor: BattleActor in Encounter.enemies:
		QuestManager.notify_enemy_defeated(actor.name)
	for actor: BattleActor in Encounter.enemies:
		xp_total += actor.xp_reward
		gold_total += actor.gold_reward

	textbox.replace("The party gains %d XP!" % xp_total)
	await get_tree().create_timer(1.2).timeout

	for actor: BattleActor in Data.party:
		var leveled: bool = actor.gain_xp(xp_total)
		if leveled:
			textbox.replace("%s reached Level %d!" % [
				actor.name,
				actor.level
			])
			await get_tree().create_timer(1.2).timeout

	Data.gold += gold_total

	textbox.replace("Received %d Gold!" % gold_total)
	await get_tree().create_timer(1.2).timeout
	Encounter.won = true
	await BattleManager.end_battle()
func battle_lost() -> void:
	textbox.replace("The party has fallen...")
	await get_tree().create_timer(1.5).timeout
	await BattleManager.defeat()
