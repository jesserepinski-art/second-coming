extends Area2D
class_name Chest

@export var chest_id: String = ""  
@export var item: Item = null
@export var equipment: Equipment = null
@export var gold_amount: int = 0
@export var quantity: int = 1
@export var open_sound: AudioStream
@export var open_sound_volume_db: float = -10.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var player_in_range := false
var opened := false

func _ready() -> void:
	if chest_id == "":
		push_warning("Chest has no chest_id set — save/load won't track it correctly!")

	if StoryFlags.has_flag("chest_opened_" + chest_id):
		_set_opened_state(true)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if opened or not player_in_range:
		return

	if event.is_action_pressed("interact"):
		_open()
		get_viewport().set_input_as_handled()

func _open() -> void:
	opened = true
	StoryFlags.set_flag("chest_opened_" + chest_id)
	_set_opened_state(true)
	
	var lines: Array[String] = []
	SfxManager.play(open_sound, open_sound_volume_db)
	if item:
		Data.item_inventory.add_item(item)
		Data.item_inventory.get_item_by_name(item.display_name).quantity = quantity
		lines.append("Found %s!" % item.display_name)

	if equipment:
		Data.equipment_inventory.append(equipment)
		lines.append("Found %s!" % equipment.display_name)

	if gold_amount > 0:
		Data.gold += gold_amount
		lines.append("Found %d Gold!" % gold_amount)

	if lines.is_empty():
		lines.append("The chest is empty.")

	await Globals.textbox.start("", lines)
	await Globals.textbox.finished

func _set_opened_state(is_opened: bool) -> void:
	if sprite:
		sprite.play("opened" if is_opened else "closed")
