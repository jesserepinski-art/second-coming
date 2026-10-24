extends Control
class_name LocationBanner

@onready var title_label: Label = $Label

func _enter_tree() -> void:
	Globals.location_banner = self

func _ready() -> void:
	modulate.a = 0.0
	hide()

func show_location(text: String, hold_time: float = 2.5) -> void:
	title_label.text = text
	modulate.a = 0.0
	show()

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.6)
	tween.tween_interval(hold_time)
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	hide()
