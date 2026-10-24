extends Control
class_name PartyScreen

@onready var party_menu: PartyMenu = $PartyMenu
@onready var stats_panel: Control = $StatsPanel

@onready var name_label: Label = $StatsPanel/NameLabel
@onready var level_label: Label = $StatsPanel/LevelLabel
@onready var hp_label: Label = $StatsPanel/HPLabel
@onready var mp_label: Label = $StatsPanel/MPLabel
@onready var attack_label: Label = $StatsPanel/AttackLabel
@onready var magic_attack_label: Label = $StatsPanel/MagicAttackLabel
@onready var defense_label: Label = $StatsPanel/DefenseLabel
@onready var speed_label: Label = $StatsPanel/SpeedLabel
@onready var accuracy_label: Label = $StatsPanel/AccuracyLabel
@onready var evasion_label: Label = $StatsPanel/EvasionLabel
@onready var crit_label: Label = $StatsPanel/CritLabel
@onready var xp_label: Label = $StatsPanel/XPLabel
@onready var equipment_label: Label = $StatsPanel/EquipmentLabel
@onready var portrait_rect: TextureRect = $StatsPanel/PortraitRect
func _ready() -> void:
	party_menu.button_pressed.connect(_on_party_button_pressed)
	stats_panel.visible = false
func _unhandled_input(event: InputEvent) -> void:
	if stats_panel.visible and event.is_action_pressed("ui_cancel"):
		stats_panel.visible = false
		party_menu.button_focus()
		get_viewport().set_input_as_handled()
func open() -> void:
	show()
	
	stats_panel.visible = false
	party_menu.party = Data.party
	party_menu.button_focus()
	await Menu.slide_fade_in(self)

func close() -> void:
	await Menu.slide_fade_out(self)
	hide()

func _on_party_button_pressed(_button: BaseButton, index: int) -> void:
	if index >= Data.party.size():
		return

	var actor: BattleActor = Data.party[index]
	_display_stats(actor)

func _display_stats(actor: BattleActor) -> void:
	stats_panel.visible = true

	portrait_rect.texture = actor.portrait
	portrait_rect.visible = actor.portrait != null
	name_label.text = actor.name
	level_label.text = "Level %d" % actor.level
	hp_label.text = "HP: %d / %d" % [actor.hp, actor.hp_max]
	mp_label.text = "MP: %d / %d" % [actor.mp, actor.mp_max]
	attack_label.text = "Attack: %d" % actor.get_attack()
	magic_attack_label.text = "Magic Attack: %d" % actor.get_magic_attack()
	defense_label.text = "Defense: %d" % actor.get_defense()
	speed_label.text = "Speed: %d" % actor.get_speed()
	accuracy_label.text = "Accuracy: %d%%" % actor.get_accuracy()
	evasion_label.text = "Evasion: %d%%" % actor.get_evasion()
	crit_label.text = "Crit: %d%%" % actor.crit_chance
	xp_label.text = "XP: %d / %d" % [actor.xp, actor.xp_to_next]

	var weapon_name := actor.equipped_weapon.display_name if actor.equipped_weapon else "None"
	var armor_name := actor.equipped_armor.display_name if actor.equipped_armor else "None"
	var trinket_name := actor.equipped_trinket.display_name if actor.equipped_trinket else "None"
	equipment_label.text = "Weapon: %s\nArmor: %s\nTrinket: %s" % [weapon_name, armor_name, trinket_name]
