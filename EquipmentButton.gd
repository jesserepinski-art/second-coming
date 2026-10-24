class_name EquipmentButton
extends Button
var equipment: Equipment = null:
	set(value):
		equipment = value
		if equipment:
			text = equipment.display_name
		else:
			text = "(Empty)"
