extends Control
class_name EquipmentScreen
@onready var party_menu: PartyMenu = $PartyMenu
@onready var slot_menu: SlotMenu = $SlotMenu
@onready var equipment_menu: EquipmentMenu = $EquipmentMenu


var selected_actor: BattleActor = null
var selected_slot: Equipment.Slot = Equipment.Slot.WEAPON

func _ready() -> void:
	party_menu.button_pressed.connect(_on_party_button_pressed)
	slot_menu.button_pressed.connect(_on_slot_button_pressed)
	equipment_menu.button_pressed.connect(_on_equipment_button_pressed)

func open() -> void:
	show()
	await Menu.slide_fade_in(self)
	slot_menu.hide()
	equipment_menu.hide()
	selected_actor = null

	party_menu.party = Data.party
	party_menu.show()
	party_menu.button_focus()

func _on_party_button_pressed(_button: BaseButton, index: int) -> void:
	if index >= Data.party.size():
		return
	selected_actor = Data.party[index]
	party_menu.hide()
	slot_menu.refresh(selected_actor)
	slot_menu.button_focus()

func _on_slot_button_pressed(_button: BaseButton, index: int) -> void:
	selected_slot = index as Equipment.Slot
	slot_menu.hide()
	equipment_menu.show_for_slot(selected_slot)
	equipment_menu.button_focus()

func _on_equipment_button_pressed(_button: BaseButton, index: int) -> void:
	if index >= equipment_menu.equipment_list.size():
		return
	var chosen: Equipment = equipment_menu.equipment_list[index]
	var previous: Equipment = selected_actor.equip(chosen) if chosen else selected_actor.unequip(selected_slot)
	if chosen:
		Data.equipment_inventory.erase(chosen)
	if previous:
		Data.equipment_inventory.append(previous)
	slot_menu.refresh(selected_actor)
	equipment_menu.close(true)   
