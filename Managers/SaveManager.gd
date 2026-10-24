extends Node

const SAVE_PATH := "user://save_1.tres"
var pending_load: SaveData = null
var reserve: Dictionary = {}
const SLOT_COUNT := 5
var current_slot := 1
var session_start := 0.0
var base_playtime := 0.0  

func _ready() -> void:
	session_start = Time.get_ticks_msec() / 1000.0
func slot_path(slot: int) -> String:
	return "user://save_%d.tres" % slot



func has_save(slot: int) -> bool:
	return FileAccess.file_exists(slot_path(slot))

func latest_slot() -> int:
	var best := -1
	var best_time := 0
	for i in range(1, SLOT_COUNT + 1):
		if has_save(i):
			var t := FileAccess.get_modified_time(slot_path(i))
			if t > best_time:
				best_time = t
				best = i
	return best

func save_game(slot: int = current_slot) -> void:
	if BattleManager.current_battle:
		return
	var lm = get_tree().root.get_node("Main/LevelManager")
	var player = get_tree().get_first_node_in_group("player")

	var s := SaveData.new()
	s.level_path = lm.current_level.scene_file_path
	s.player_position = player.global_position
	s.gold = Data.gold
	for a in Data.party: s.party.append(a)
	for i in Data.item_inventory.items: s.items.append(i)
	for e in Data.equipment_inventory: s.equipment.append(e)
	s.flags = StoryFlags.flags.duplicate()
	s.active_quests.assign(QuestManager.active_quest_ids)
	s.quest_steps = QuestManager.step_index.duplicate()
	ResourceSaver.save(s, SAVE_PATH)
	s.location_name = lm.current_level.location_name if "location_name" in lm.current_level else ""
	s.saved_at = Time.get_datetime_string_from_system()
	s.playtime = base_playtime + (Time.get_ticks_msec() / 1000.0 - session_start)
	ResourceSaver.save(s, slot_path(slot))
	current_slot = slot
func load_game(slot: int) -> bool:
	if not has_save(slot):
		return false
	current_slot = slot
	pending_load = ResourceLoader.load(slot_path(slot), "", ResourceLoader.CACHE_MODE_IGNORE) as SaveData
	if pending_load:
		base_playtime = pending_load.playtime
		session_start = Time.get_ticks_msec() / 1000.0
	return pending_load != null
	
	
	
func apply_pending() -> void:
	var s := pending_load
	pending_load = null
	Data.gold = s.gold
	Data.party.clear()
	for a in s.party: Data.party.append(a)
	Data.item_inventory = Inventory.new()
	for i in s.items: Data.item_inventory.items.append(i)
	Data.equipment_inventory.clear()
	for e in s.equipment: Data.equipment_inventory.append(e)
	StoryFlags.flags = s.flags
	QuestManager.active_quest_ids.assign(s.active_quests)
	QuestManager.step_index = s.quest_steps

func new_game() -> void:
	StoryFlags.flags.clear()
	QuestManager.active_quest_ids.clear()
	QuestManager.step_index.clear()
	Data.gold = 0
	Data.item_inventory = Inventory.new()
	Data.equipment_inventory.clear()
	Data.start_new_game()
	base_playtime = 0.0
	session_start = Time.get_ticks_msec() / 1000.0
func slot_label(slot: int) -> String:
	if not has_save(slot):
		return "Slot %d - Empty" % slot
	var s := ResourceLoader.load(slot_path(slot), "", ResourceLoader.CACHE_MODE_IGNORE) as SaveData
	var mins := int(s.playtime / 60.0)
	return "Slot %d - %s - %d:%02d" % [slot, s.location_name, floori(mins / 60.0), mins % 60]
