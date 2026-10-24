extends Control
class_name QuestScreen

@onready var main_quest_menu: Menu = $TabContainer/Main/MainQuestMenu
@onready var side_quest_menu: Menu = $TabContainer/Side/SideQuestMenu
@onready var description_label: Label = $DetailPanel/DescriptionLabel
@onready var goal_label: Label = $DetailPanel/GoalLabel
@onready var reward_label: Label = $DetailPanel/RewardLabel
@onready var tabs: TabContainer = $TabContainer



func _ready() -> void:
	main_quest_menu.button_pressed.connect(_on_quest_selected.bind(true))
	side_quest_menu.button_pressed.connect(_on_quest_selected.bind(false))
	hide()
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("tab_next"):
		tabs.current_tab = (tabs.current_tab + 1) % tabs.get_tab_count()
		_focus_current_tab()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("tab_prev"):
		tabs.current_tab = (tabs.current_tab - 1 + tabs.get_tab_count()) % tabs.get_tab_count()
		_focus_current_tab()
		get_viewport().set_input_as_handled()

func _focus_current_tab() -> void:
	if tabs.current_tab == 0:
		main_quest_menu.button_focus()
	else:
		side_quest_menu.button_focus()
func open() -> void:
	show()
	await Menu.slide_fade_in(self)
	_populate(main_quest_menu, true)
	_populate(side_quest_menu, false)
	main_quest_menu.button_focus()

func close() -> void:
	await Menu.slide_fade_out(self)
	hide()

func _populate(menu: Menu, is_main: bool) -> void:
	var active: Array[Quest] = []
	for id in QuestManager.active_quest_ids:
		var quest := QuestManager._find_quest(id)
		if quest and quest.is_main_quest == is_main:
			active.append(quest)

	for button: QuestButton in menu.get_buttons():
		var idx := button.get_index()
		button.quest = active[idx] if idx < active.size() else null

func _on_quest_selected(_button: BaseButton, index: int, is_main: bool) -> void:
	var menu := main_quest_menu if is_main else side_quest_menu
	if index >= menu.get_buttons().size():
		return

	var button: QuestButton = menu.get_buttons()[index]
	var quest: Quest = button.quest
	var step := QuestManager._current_objective(quest)
	if quest == null:
		return
	
	description_label.text = quest.description
	goal_label.text = "Goal: " + (step.description if step else _describe_objective(quest))
	reward_label.text = "Reward: %d Gold%s" % [
		quest.reward_gold,
		", " + quest.reward_item.display_name if quest.reward_item else ""
	]
	if step and not step.choice_quest_ids.is_empty():
		var needed : float = step.required_count if step.required_count > 0 else step.choice_quest_ids.size()
		goal_label.text = "Goal: %s (%d/%d)" % [step.description, QuestManager.choices_done(step), needed]
func _describe_objective(quest: Quest) -> String:
	match quest.objective_type:
		Quest.ObjectiveType.DEFEAT_ENEMY:
			return "Defeat " + quest.target_name
		Quest.ObjectiveType.REACH_LOCATION:
			return "Reach " + quest.target_name
		Quest.ObjectiveType.ITEM_OBTAINED:
			return "Obtain " + quest.target_name
		Quest.ObjectiveType.FLAG_SET:
			return "Search for" + quest.target_name  
		_:
			return ""
