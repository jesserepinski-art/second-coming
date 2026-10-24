extends PanelContainer
class_name BanterBox

@onready var speaker_label: Label = $MarginContainer/VBoxContainer/Speaker
@onready var dialogue_label: Label = $MarginContainer/VBoxContainer/Dialogue
@onready var portrait_rect: TextureRect = $MarginContainer/PortraitRect

var current_text: String = ""

func _enter_tree() -> void:
	Globals.banter_box = self

func _ready() -> void:
	modulate.a = 0.0
	hide()

func play_line(speaker: String, text: String, portrait: Texture2D, hold_time: float = 1.2) -> void:
	speaker_label.text = speaker
	portrait_rect.texture = portrait
	portrait_rect.visible = portrait != null

	current_text = text
	dialogue_label.text = ""

	modulate.a = 0.0
	show()

	var fade_in := create_tween()
	fade_in.tween_property(self, "modulate:a", 1.0, 0.2)
	await fade_in.finished

	for i in range(current_text.length()):
		dialogue_label.text = current_text.substr(0, i + 1)
		await get_tree().create_timer(0.03).timeout

	await get_tree().create_timer(hold_time).timeout

	var fade_out := create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.2)
	await fade_out.finished

	hide()
