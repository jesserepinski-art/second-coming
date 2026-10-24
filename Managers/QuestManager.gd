extends Node

var quest_pool: Array[Quest] = []
var active_quest_ids: Array[String] = []
var step_index: Dictionary

func _ready() -> void:
	_load_quest_pool("res://Quests/")

func _load_quest_pool(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var resource := load(path + file_name)
				if resource is Quest:
					quest_pool.append(resource)
			file_name = dir.get_next()

func start_quest(quest_id: String) -> void:
	if active_quest_ids.has(quest_id) or StoryFlags.has_flag("quest_completed_" + quest_id):
		return
	active_quest_ids.append(quest_id)
	StoryFlags.set_flag("quest_active_" + quest_id)
	step_index[quest_id] = 0
	_begin_step(quest_id)
	
func _begin_step(quest_id: String) -> void:
	var quest := _find_quest(quest_id)
	if quest == null or quest.steps.is_empty():
		return
	var step := quest.steps[step_index[quest_id]]
	if step.start_quest_id != "":
		start_quest(step.start_quest_id)
	for id in step.choice_quest_ids:
		start_quest(id)
	if step.objective_type == Quest.ObjectiveType.FLAG_SET and StoryFlags.has_flag(step.target_name):
		_advance(quest_id)
	elif not step.choice_quest_ids.is_empty():
		_check_choices(quest_id)


func _advance(quest_id: String) -> void:
	var quest := _find_quest(quest_id)
	if quest == null:
		return
	if quest.steps.is_empty():
		complete_quest(quest_id)
		return

	var step := quest.steps[step_index[quest_id]]
	if step.step_flag != "":
		StoryFlags.set_flag(step.step_flag)

	step_index[quest_id] += 1
	if step_index[quest_id] >= quest.steps.size():
		complete_quest(quest_id)
	else:
		_begin_step(quest_id)

func _current_objective(quest: Quest) -> QuestStep:
	if quest.steps.is_empty():
		return null
	
	var idx = step_index.get(quest.quest_id, 0)
	
	if idx >= quest.steps.size():
		return null
		
	return quest.steps[idx]

func complete_quest(quest_id: String) -> void:
	if not active_quest_ids.has(quest_id):
		return
	
	
	
	active_quest_ids.erase(quest_id)
	StoryFlags.set_flag("quest_completed_" + quest_id)

	
	for parent_id in active_quest_ids.duplicate():
		var parent := _find_quest(parent_id)
		if parent == null:
			continue
		var step := _current_objective(parent)
		if step == null:
			continue
		if step.choice_quest_ids.has(quest_id):
			_check_choices(parent_id)
		elif step.required_quest_id == quest_id:
			_advance(parent_id)

	var quest := _find_quest(quest_id)
	if quest == null:
		return

	if quest.completion_flag != "":
		StoryFlags.set_flag(quest.completion_flag)
	if quest.reward_gold > 0:
		Data.gold += quest.reward_gold
	if quest.reward_item:
		Data.item_inventory.add_item(quest.reward_item)

func _notify(type: Quest.ObjectiveType, target_value: String) -> void:
	for id in active_quest_ids.duplicate():
		var quest := _find_quest(id)
		if quest == null:
			continue
		var step := _current_objective(quest)
		var step_type := step.objective_type if step else quest.objective_type
		var step_target := step.target_name if step else quest.target_name
		if step_type == type and step_target == target_value:
			_advance(id)

func notify_enemy_defeated(enemy_name: String) -> void:
	_notify(Quest.ObjectiveType.DEFEAT_ENEMY, enemy_name)

func notify_location_reached(location_name: String) -> void:
	_notify(Quest.ObjectiveType.REACH_LOCATION, location_name)

func notify_flag_set(flag_name: String) -> void:
	_notify(Quest.ObjectiveType.FLAG_SET, flag_name)

func _find_quest(quest_id: String) -> Quest:
	for q in quest_pool:
		if q.quest_id == quest_id:
			return q
	return null
func choices_done(step: QuestStep) -> int:
	var n := 0
	for id in step.choice_quest_ids:
		if StoryFlags.has_flag("quest_completed_" + id):
			n += 1
	return n

func _check_choices(parent_id: String) -> void:
	var quest := _find_quest(parent_id)
	var step := _current_objective(quest)
	var needed : float = step.required_count if step.required_count > 0 else step.choice_quest_ids.size()
	if choices_done(step) >= needed:
		_advance(parent_id)
