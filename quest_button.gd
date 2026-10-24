class_name QuestButton
extends Button

var quest: Quest = null:
	set(value):
		quest = value
		text = quest.title if quest else ""
