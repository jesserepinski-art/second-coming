class_name SpellMenu
extends Menu


@onready var description_label: Label = $InfoPanel/InfoText

var spells: Array[Item] = []:
	set(value):
		spells = value

		var buttons := get_buttons()

		for i in buttons.size():
			var button: ItemButton = buttons[i]

			if i < spells.size():
				button.show()
				button.disabled = false
				button.item = spells[i]
				
				
				if not button.focus_entered.is_connected(_on_button_focus_entered):
					button.focus_entered.connect(_on_button_focus_entered.bind(button))
			else:
				button.item = null
				button.disabled = true
				button.hide()
				
				
				if button.focus_entered.is_connected(_on_button_focus_entered):
					button.focus_entered.disconnect(_on_button_focus_entered)

func refresh() -> void:
	await get_tree().process_frame
	_set_focus_neighbors()

func _ready() -> void:
	super()
	hide()
	if description_label:
		description_label.text = ""


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
