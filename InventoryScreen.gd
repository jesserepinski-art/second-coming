extends Control
class_name InventoryScreen

@onready var tabs: TabContainer = $TabContainer
@onready var items_tab: InventoryMenu = $TabContainer/Items/ItemsInventoryMenu
@onready var equipment_tab: EquipmentScreen = $TabContainer/Equipment/EquipmentScreen

func open() -> void:
	visible = true
	await Menu.slide_fade_in(self)
	items_tab.inventory = Data.item_inventory
	items_tab.button_focus()
	equipment_tab.open()

func close() -> void:
	await Menu.slide_fade_out(self)
	visible = false

func _unhandled_input(event: InputEvent) -> void:
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
		items_tab.button_focus()
	else:
		equipment_tab.party_menu.button_focus()
