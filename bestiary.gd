class_name Bestiary extends Node

func _ready() -> void:
	Globals.Bestiary = self


func has_seen(enemy_name: String) -> bool:
	return StoryFlags.has_flag("bestiary_seen_" + enemy_name)

func mark_seen(enemy_name: String) -> void:
	StoryFlags.set_flag("bestiary_seen_" + enemy_name)
