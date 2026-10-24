extends CanvasLayer
class_name PauseMenu
@onready var slot_screen: SlotScreen = $SlotScreen
@onready var options_menu: PauseOptionsMenu = $Panel/Options
@onready var inventory_screen: InventoryScreen = $InventoryScreen
@onready var party_screen: PartyScreen = $PartyScreen
@onready var stat_allocation_screen: StatAllocationScreen = $StatAllocationScreen
@onready var quest_screen: QuestScreen = $QuestScreen
@onready var bestiary_screen: BestiaryScreen = $BestiaryScreen
var is_open := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	inventory_screen.visible = false
	inventory_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	party_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	stat_allocation_screen.visible = false
	stat_allocation_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	quest_screen.visible = false
	quest_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	bestiary_screen.visible = false
	bestiary_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	options_menu.button_pressed.connect(_on_options_button_pressed)
	slot_screen.visible = false
func toggle_pause() -> void:
	is_open = not is_open
	get_tree().paused = is_open
	if is_open:
		visible = true
		await Menu.slide_fade_in($Panel)
		options_menu.button_focus()
	else:
		await Menu.slide_fade_out($Panel)
		visible = false
func _on_options_button_pressed(_button: BaseButton, index: int) -> void:
	match index:
		0: _on_inventory_pressed()
		1: _on_party_pressed()
		2: _on_stats_pressed()
		3: _on_quests_pressed()
		4: _on_bestiary_pressed()
		5: _on_load_pressed()
		6: _on_close_pressed()
func _on_load_pressed() -> void:
	$Panel.visible = false
	var slot: int = await slot_screen.pick("load")
	if slot == -1:
		$Panel.visible = true
		options_menu.button_focus()
		return
	if SaveManager.load_game(slot):
		await TransitionManager.fade_to_black(0.5)
		get_tree().paused = false
		Menu.tree.clear()
		get_tree().change_scene_to_file("res://Main.tscn")
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if inventory_screen.visible:
			close_inventory()
		elif party_screen.visible:
			close_party()
		elif stat_allocation_screen.visible:
			close_stats()
		elif quest_screen.visible:
			close_quests()
		elif bestiary_screen.visible:
			close_bestiary()
		elif slot_screen.visible:
			slot_screen.cancel()
		else:
			toggle_pause()

func _on_inventory_pressed() -> void:
	options_menu.hide()
	$Panel.visible = false
	inventory_screen.open()
	

func close_inventory() -> void:
	inventory_screen.close()
	$Panel.visible = true
	options_menu.show()
func _on_party_pressed() -> void:
	options_menu.hide()
	
	party_screen.open()

func close_party() -> void:
	party_screen.close()
	
	options_menu.show()
func _on_stats_pressed() -> void:
	options_menu.hide()
	$Panel.visible = false
	stat_allocation_screen.open()

func close_stats() -> void:
	stat_allocation_screen.close()
	$Panel.visible = true
	options_menu.show()
func _on_save_pressed() -> void:
	SaveManager.save_game()
	await Globals.textbox.start("", ["Game saved!"])
	await Globals.textbox.finished

func _on_close_pressed() -> void:
	toggle_pause()
func _on_quests_pressed() -> void:
	options_menu.hide()
	$Panel.visible = false
	quest_screen.open()

func close_quests() -> void:
	quest_screen.close()
	$Panel.visible = true
	options_menu.show()
func _on_bestiary_pressed() -> void:
	options_menu.hide()
	$Panel.visible = false
	bestiary_screen.open()

func close_bestiary() -> void:
	bestiary_screen.close()
	$Panel.visible = true
	options_menu.show()
