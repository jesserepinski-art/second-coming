class_name PartyButton
extends Button
var actor: BattleActor = null:
	set(value):
		actor = value
		if actor:
			text = actor.name
		else:
			text = ""
