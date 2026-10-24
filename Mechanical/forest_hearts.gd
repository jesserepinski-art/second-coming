extends Area2D
class_name ForestHearts

signal activated

@export var switch_id: String = ""
@export var required_item_name: String = ""  
@export var one_time_use: bool = true
@onready var sound: AudioStreamPlayer = $Sound
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var player_in_range := false
var used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if switch_id != "" and StoryFlags.has_flag("switch_used_" + switch_id):
		used = true
		if sprite:
			sprite.play("pressed")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if not player_in_range or (used and one_time_use):
		return

	if event.is_action_pressed("interact"):
		_try_activate()
		get_viewport().set_input_as_handled()

func _try_activate() -> void:
	if required_item_name != "" and not Data.item_inventory.get_item_by_name(required_item_name):
		await Globals.textbox.start("", ["It won't budge. Something else is needed."])
		await Globals.textbox.finished
		return

	used = true
	if switch_id != "":
		StoryFlags.set_flag("switch_used_" + switch_id)
	if sound:
		sound.play()
	if sprite:
		
		sprite.play("exorcising")
		await get_tree().create_timer(2.0).timeout
		sprite.play("exorcised")
		var tween = create_tween()
	
	
		tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 1.0)
		

	activated.emit()
