class_name PlayerWindow extends Button
const STATUS_ICON = preload("res://status_icon.tscn")
var tween: Tween = null
@onready var status_icons := $StatusIcons
@onready var start_y: float = position.y
@onready var p_name: Label = $PanelContainer/VBoxContainer/PName
@onready var hp: Label = $PanelContainer/VBoxContainer/HP/HP
@onready var mp: Label = $PanelContainer/VBoxContainer/MP/MP



var data: BattleActor = null :
	set(value):
		
		if data:
			if data.hp_changed.is_connected(_on_data_hp_changed):
				data.hp_changed.disconnect(_on_data_hp_changed)

			if data.statuses_changed.is_connected(_on_statuses_changed):
				data.statuses_changed.disconnect(_on_statuses_changed)

		data = value

		if data:
			data.hp_changed.connect(_on_data_hp_changed)
			data.statuses_changed.connect(_on_statuses_changed)

			p_name.text = data.name.erase(8, 99)
			hp.text = str(data.hp)
			mp.text = str(data.mp)

			refresh_status_icons()
			show()
		else:
			hide()
		
func activate(enabled: bool) -> void:
	pass

func _on_data_hp_changed(hp: int, _hp_max: int, value: int) -> void:
	if value < 0:
		if Globals.battle_effects:
			Globals.battle_effects.play_hurt_sound(data)

	self.hp.text = str(hp)

	refresh_status_icons()
func refresh_status_icons() -> void:
	
	
	for child in status_icons.get_children():
		child.queue_free()

	if data == null:
		return
	
	
	for status: StatusEffect in data.statuses:

		@warning_ignore("shadowed_variable_base_class")
		var icon := STATUS_ICON.instantiate()
		icon.texture = status.icon
		status_icons.add_child(icon)
	

func _on_statuses_changed() -> void:

	refresh_status_icons()
func reset_start_position():
	start_y = position.y
