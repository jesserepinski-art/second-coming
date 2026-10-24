extends CharacterBody2D
class_name Shopkeeper

@export var shop_items: Array[Item] = []
@export var shop_equipment: Array[Equipment] = []
@export var greeting: String = "Welcome. Take a look."

func interact() -> void:
	Globals.shop_screen.open(shop_items, shop_equipment)
