extends Node

var flags: Dictionary = {}

func set_flag(flag_name: String, value := true) -> void:
	flags[flag_name] = value
	if value and not flag_name.begins_with("quest_"):
		QuestManager.notify_flag_set(flag_name)

func has_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)

func has_flags(flag_list: Array[String]) -> bool:
	for flag in flag_list:
		if not has_flag(flag):
			return false 
	return true 

func clear_flag(flag_name: String) -> void:
	flags.erase(flag_name)
