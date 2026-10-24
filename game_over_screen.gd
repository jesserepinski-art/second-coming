extends CanvasLayer
class_name GameOverScreen

signal chosen
var chose_continue := false

@onready var buttons: Menu = $Control/Buttons

func _enter_tree() -> void:
	Globals.game_over_screen = self

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	buttons.button_pressed.connect(_on_pressed)

func show_screen() -> void:
	$Control/Buttons/List/ContinueButton.disabled = not SaveManager.has_save(SaveManager.current_slot)
	show()
	buttons.button_focus()
	await chosen
	hide()

func _on_pressed(_b: BaseButton, index: int) -> void:
	chose_continue = (index == 0)
	Menu.tree.clear()
	chosen.emit()
