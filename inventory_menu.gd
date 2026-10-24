class_name InventoryMenu extends Menu

@onready var description_label: Label = $PanelContainer/Label 

var inventory: Inventory = null:
	set(value):
		if inventory == value:
			return
		inventory = value
		
		for button: ItemButton in get_buttons():
			var item_data = inventory.get_item_by_position(button.get_index())
			
			if item_data != null:
				button.item = item_data
				button.disabled = false
				button.text = item_data.display_name 
				button.focus_mode = Control.FOCUS_ALL
				
				if not button.focus_entered.is_connected(_on_button_focus_entered):
					button.focus_entered.connect(_on_button_focus_entered.bind(button))
			else:
				button.item = null
				button.disabled = true
				button.text = "---" 
				button.focus_mode = Control.FOCUS_NONE 
				
				
				if button.focus_entered.is_connected(_on_button_focus_entered):
					button.focus_entered.disconnect(_on_button_focus_entered)

func _ready() -> void:
	super()
	hide()
	if description_label:
		description_label.text = ""

func refresh() -> void:
	await get_tree().process_frame
	_set_focus_neighbors()


func _on_button_focus_entered(button: ItemButton) -> void:
	if description_label == null:
		return
		
	if button and button.item:
		if "description" in button.item and not button.item.description.is_empty():
			description_label.text = button.item.description
		else:
			description_label.text = "No description available."
	else:
		description_label.text = ""


func close(toggle: bool = false) -> bool:
	var closed = super(toggle)
	if closed and description_label:
		description_label.text = ""
	return closed
