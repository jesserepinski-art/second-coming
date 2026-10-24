class_name Quest extends Resource

enum ObjectiveType { DEFEAT_ENEMY, REACH_LOCATION, FLAG_SET, ITEM_OBTAINED }

@export var quest_id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var is_main_quest: bool = true
@export var steps: Array[QuestStep] = []
@export var objective_type: ObjectiveType = ObjectiveType.DEFEAT_ENEMY
@export var target_name: String = ""  
@export var required_flag: String = ""  

@export var completion_flag: String = ""  
@export var reward_gold: int = 0
@export var reward_item: Item = null
