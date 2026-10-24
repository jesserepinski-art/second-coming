class_name ShopButton
extends Button

var goods = null:
	set(value):
		goods = value
		if goods:
			text = "%s - %dg" % [goods.display_name, goods.value]
		else:
			text = ""
