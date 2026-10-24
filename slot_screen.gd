extends Control
class_name SlotScreen

signal picked(slot: int)
@onready var slot_menu: Menu = $SlotMenu
var mode := "load"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	slot_menu.button_pressed.connect(_on_slot_pressed)
	hide()

func pick(new_mode: String = "load") -> int:
	mode = new_mode
	for button: Button in slot_menu.get_buttons():
		var slot := button.get_index() + 1
		button.text = SaveManager.slot_label(slot)
		button.disabled = mode == "load" and not SaveManager.has_save(slot)
	show()
	slot_menu.button_focus()
	var result: int = await picked
	slot_menu.release()
	Menu.tree.erase(slot_menu)
	hide()
	return result

func cancel() -> void:
	picked.emit(-1)

func _on_slot_pressed(_b: BaseButton, index: int) -> void:
	picked.emit(index + 1)

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		cancel()
		get_viewport().set_input_as_handled()
