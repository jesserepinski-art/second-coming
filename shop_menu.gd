class_name ShopMenu extends Menu

var stock: Array = []:
	set(value):
		stock = value
		for button: ShopButton in get_buttons():
			button.goods = stock[button.get_index()] if button.get_index() < stock.size() else null

func _ready() -> void:
	super()
	hide()
