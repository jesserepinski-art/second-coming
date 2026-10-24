class_name EquipmentMenu extends Menu

var equipment_list: Array[Equipment] = []:
	set(value):
		equipment_list = value
		for button: EquipmentButton in get_buttons():
			button.equipment = equipment_list[button.get_index()] if button.get_index() < equipment_list.size() else null

		if get_buttons().size() > 0 and equipment_list.size() > 0 and equipment_list[0] == null:
			get_buttons()[0].text = "(Unequip)"

func _ready() -> void:
	super()
	hide()

func show_for_slot(slot: Equipment.Slot) -> void:
	print("FULL equipment_inventory: ", Data.equipment_inventory)
	var filtered: Array[Equipment] = [null]
	for gear: Equipment in Data.equipment_inventory:
		if int(gear.slot) == int(slot):
			filtered.append(gear)
	print("show_for_slot: ", filtered)
	equipment_list = filtered
