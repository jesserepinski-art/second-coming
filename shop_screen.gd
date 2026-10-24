extends Control
class_name ShopScreen

@onready var shop_menu: ShopMenu = $ShopMenu

var current_stock: Array = []

func _enter_tree() -> void:
	Globals.shop_screen = self

func _ready() -> void:
	shop_menu.button_pressed.connect(_on_item_pressed)
	hide()

func open(items: Array[Item], equipment: Array[Equipment]) -> void:
	current_stock = []
	current_stock.append_array(items)
	current_stock.append_array(equipment)

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.process_mode = Node.PROCESS_MODE_DISABLED
	await Menu.slide_fade_in(self)
	show()
	shop_menu.stock = current_stock
	shop_menu.button_focus()

func close() -> void:
	await Menu.slide_fade_out(self)
	hide()

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.process_mode = Node.PROCESS_MODE_INHERIT

func _on_item_pressed(_button: BaseButton, index: int) -> void:
	if index >= current_stock.size():
		return

	var goods = current_stock[index]
	var price: int = goods.value

	if Data.gold < price:
		await Globals.textbox.start("", ["Not enough gold."])
		await Globals.textbox.finished
		return

	Data.gold -= price

	if goods is Item:
		Data.item_inventory.add_item(goods)
	elif goods is Equipment:
		Data.equipment_inventory.append(goods.duplicate())

	await Globals.textbox.start("", ["Bought %s." % goods.display_name])
	await Globals.textbox.finished

	shop_menu.button_focus(index)

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
