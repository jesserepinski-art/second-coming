class_name Inventory extends Resource

signal updated()

var items: Array = []
var max_size: int = 10

func get_items() -> Array:
	return items

func get_size() -> int:
	return items.size()

func get_item_by_name(item_name: String) -> Item:
	for item: Item in items:
		if item.display_name == item_name:
			return item
	return null

func get_item_by_position(pos: int) -> Item:
	if pos < items.size():
		return items[pos]
	return null

func add_item_by_name(item_name: String, quantity: int = 1) -> bool:
	var item: Item = Data.items.get(item_name)
	
	if not item:
		return false
	
	if item.stackable:
		var existing_stack: Item = get_item_by_name(item_name)
		if existing_stack:
			existing_stack.quantity += quantity
			return true
	
	if get_size() < max_size:
		var new_item: Item = item.duplicate_custom()
		new_item.quantity = quantity
		items.append(new_item)
		updated.emit()
		return true
	
	return false

func add_item(item: Item) -> bool:
	if not item:
		return false
	
	return add_item_by_name(item.display_name, item.quantity)

func remove_item(item: Item) -> bool:
	if not item:
		return false
	
	item.quantity -= 1
	if item.quantity == 0:
		items.erase(item)
	updated.emit()
	return true
