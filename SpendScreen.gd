extends Control
class_name StatAllocationScreen

@onready var party_menu: PartyMenu = $PartyMenu
@onready var stat_menu: Menu = $StatMenu
@onready var points_label: Label = $PointsLabel
@onready var stats_label: Label = $StatsLabel

var selected_actor: BattleActor = null

func _ready() -> void:
	party_menu.button_pressed.connect(_on_party_button_pressed)
	stat_menu.button_pressed.connect(_on_stat_button_pressed)
	hide()

func open() -> void:
	show()
	selected_actor = null
	points_label.text = ""
	stats_label.text = ""
	points_label.hide()
	stats_label.hide()
	stat_menu.hide()

	party_menu.party = Data.party
	party_menu.show()
	party_menu.button_focus()

func close() -> void:
	for m: Menu in [party_menu, stat_menu]:
		m.release()
		Menu.tree.erase(m)
		m.hide()
	selected_actor = null
	hide()

func _on_party_button_pressed(_button: BaseButton, index: int) -> void:
	if index >= Data.party.size():
		return
	selected_actor = Data.party[index]
	_refresh_display()
	points_label.show()
	stats_label.show()
	party_menu.hide()
	stat_menu.show()
	stat_menu.button_focus()
func _refresh_display() -> void:
	if selected_actor == null:
		return

	points_label.text = "Available Points: %d" % selected_actor.ability_points
	stats_label.text = "HP: %d   MP: %d   ATK: %d   MAG: %d   DEF: %d   SPD: %d   CRIT: %d%%" % [
		selected_actor.hp_max,
		selected_actor.mp_max,
		selected_actor.attack,
		selected_actor.magic_attack,
		selected_actor.defense,
		selected_actor.speed,
		selected_actor.crit_chance,
	]

func _on_stat_button_pressed(_button: BaseButton, index: int) -> void:
	if selected_actor == null:
		return

	var stat: BattleActor.StatType = index as BattleActor.StatType
	if selected_actor.spend_point(stat):
		_refresh_display()
