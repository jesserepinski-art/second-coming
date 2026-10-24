class_name QuestStep extends Resource

@export var description: String = ""
@export var objective_type: Quest.ObjectiveType = Quest.ObjectiveType.DEFEAT_ENEMY
@export var target_name: String = ""
@export var required_quest_id: String = "" 
@export var start_quest_id: String = ""     
@export var step_flag: String = ""          
@export var choice_quest_ids: Array[String] = []  
@export var required_count: int = 0              
